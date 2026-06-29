# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_keys
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invitation_id :uuid
#  recipient_id  :uuid             not null
#  world_id      :uuid             not null
#
# Indexes
#
#  index_world_keys_on_invitation_id  (invitation_id)
#  index_world_keys_on_recipient_id   (recipient_id)
#  index_world_keys_on_world_id       (world_id)
#  index_world_keys_uniqueness        (world_id,recipient_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (invitation_id => world_invitations.id)
#  fk_rails_...  (recipient_id => users.id)
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WorldKey < ApplicationRecord
  include Noticeable

  # == Associations ==

  belongs_to :world, inverse_of: :keys
  has_many :world_invitations, through: :world, source: :invitations
  has_one :world_owner, through: :world, source: :owner
  has_many :world_post_types, through: :world, source: :post_types

  has_many :post_type_grants, dependent: :destroy
  has_many :granted_post_types, through: :post_type_grants, source: :post_type

  belongs_to :recipient, class_name: "User"
  belongs_to :invitation,
    class_name: "WorldInvitation",
    optional: true,
    dependent: :destroy

  sig { returns(World) }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing associated world"
  end

  sig { returns(User) }
  def world_owner!
    world_owner or raise ActiveRecord::RecordNotFound, "Missing world owner"
  end

  sig { returns(User) }
  def recipient!
    recipient or raise ActiveRecord::RecordNotFound, "Missing recipient"
  end

  # == Validations ==

  validates :recipient, uniqueness: {
    scope: :world,
    message: ->(object, _data) {
      world = object.world!
      "already has a key to #{world.name}"
    },
  }
  validate :validate_recipient_not_world_owner, on: :create

  # == Hooks ==

  after_initialize :set_invitation, unless: :invitation_id?

  # after_destroy :discard_recipient_world_cards!,
  #   unless: :recipient_has_other_keys?
  after_create_commit :create_notification_for_world_owner!

  # == Notifications ==

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

  sig { params(grant: String).returns(GrantMessage) }
  def self.verify_grant(grant)
    GrantMessage.new(grant_verifier.verify(grant))
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(WorldInvitation)) }
  def recipient_invitation_pending_acceptance
    recipient_phone_number = User.where(id: recipient_id).select(:phone_number)
    world_invitations.pending_acceptance
      .where(recipient_id:)
      .or(world_invitations.where(recipient_phone_number:))
      .first
  end

  # == Callbacks ==

  sig { void }
  def set_invitation
    if (invitation = recipient_invitation_pending_acceptance)
      self.invitation = invitation
    end
  end

  sig { void }
  def validate_recipient_not_world_owner
    if recipient_id == world&.owner_id
      errors.add(:recipient, "cannot be the world owner")
    end
  end

  # sig { void }
  # def discard_recipient_world_cards!
  #   world = world!
  #   recipient = recipient!
  #   world.cards.kept.where(cardholder: recipient).discard_all!
  # end
end
