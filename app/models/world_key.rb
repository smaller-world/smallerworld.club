# typed: strict
# frozen_string_literal: true

# NOTE: `accepted_at` can be null in the future when a user creates a key to
# invite another user to their world directly from the app. i.e. Bob invites
# Alice to his world, she accepts his key via QR code, and then she sends a
# return-key to Bob from within the app from a CTA.
#
# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_keys
#
#  id           :uuid             not null, primary key
#  accepted_at  :timestamptz
#  color        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  recipient_id :uuid             not null
#  world_id     :uuid             not null
#
# Indexes
#
#  index_world_keys_on_accepted_at   (accepted_at)
#  index_world_keys_on_recipient_id  (recipient_id)
#  index_world_keys_on_world_id      (world_id)
#  index_world_keys_uniqueness       (world_id,recipient_id,color) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (recipient_id => users.id)
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WorldKey < ApplicationRecord
  include Noticeable

  # == Attributes ==

  enumerize :color, in: [ :green, :orange, :pink, :blue, :red ]

  # == Associations ==

  belongs_to :world, inverse_of: :keys
  has_one :world_owner, through: :world, source: :owner
  belongs_to :recipient, class_name: "User"

  sig { returns(World) }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing associated world"
  end

  sig { returns(User) }
  def world_owner!
    world_owner or raise ActiveRecord::RecordNotFound, "Missing associated world owner"
  end

  sig { returns(User) }
  def recipient!
    recipient or raise ActiveRecord::RecordNotFound, "Missing recipient"
  end

  # == Validations ==

  validates :color, presence: true
  validates :recipient, uniqueness: {
    scope: [ :world, :color ],
    message: ->(object, _data) {
      color = object.color
      article = color.start_with?("a", "e", "i", "o", "u") ? "an" : "a"
      "already has #{article} #{color} key to #{object.world!.name}"
    },
  }
  validate :validate_recipient_not_world_owner, on: :create

  # == Hooks ==

  after_destroy :discard_recipient_world_cards!,
    unless: :recipient_has_other_keys?
  after_commit :create_notification_for_world_owner!,
    on: [ :create, :update ],
    if: [ :accepted_at?, :saved_change_to_accepted_at? ]

  # == Scopes ==

  scope :accepted, -> { where.not(accepted_at: nil) }
  scope :pending_acceptance, -> { where(accepted_at: nil) }

  # == Noticeable ==

  sig { override.params(recipient: User).returns(Notification::Message) }
  def notification_message(recipient:)
    world = world!
    key_recipient = recipient!
    Notification::Message.new(
      target_url: [ world, :keys ],
      title: "#{key_recipient.name} joined your world!",
    )
  end

  sig { void }
  def create_notification_for_world_owner!
    notifications.create!(recipient: world_owner!)
  end

  # == Grants ==

  sig { returns(ActiveSupport::MessageVerifier) }
  def self.grant_verifier
    Rails.application.message_verifier(:world_key_grant)
  end

  sig { params(grant: String).returns({ world_id: String, color: String }) }
  def self.verify_grant(grant)
    grant_verifier.verify(grant).symbolize_keys
  end

  # == Methods ==

  sig { returns(String) }
  def label
    if (world = self.world)
      world.key_label(color:)
    else
      "#{color.humanize(capitalize: false)} key"
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def recipient_has_other_keys?
    WorldKey.where.not(id:).exists?(world_id:, recipient_id:)
  end

  # == Callbacks ==

  sig { void }
  def validate_recipient_not_world_owner
    if recipient_id == world&.owner_id
      errors.add(:recipient, "cannot be the world owner")
    end
  end

  sig { void }
  def discard_recipient_world_cards!
    world = world!
    recipient = recipient!
    world.cards.kept.where(cardholder: recipient).discard_all!
  end
end
