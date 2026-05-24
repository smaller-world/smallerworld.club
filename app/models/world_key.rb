# typed: true
# frozen_string_literal: true

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

  # == Scopes ==

  scope :accepted, -> { where.not(accepted_at: nil) }
  scope :pending_acceptance, -> { where(accepted_at: nil) }

  # == Grants ==

  sig { returns(ActiveSupport::MessageVerifier) }
  def self.grant_verifier
    Rails.application.message_verifier(:world_key_grant)
  end
  delegate :grant_verifier, to: :class

  sig { params(grant: String).returns({ world_id: String, color: String }) }
  def self.verify_grant(grant)
    grant_verifier.verify(grant).symbolize_keys
  end

  private

  # == Validators ==

  sig { void }
  def validate_recipient_not_world_owner
    if recipient_id == world&.owner_id
      errors.add(:recipient_id, "cannot be the world owner")
    end
  end
end
