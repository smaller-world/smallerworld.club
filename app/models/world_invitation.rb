# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_invitations
#
#  id                     :uuid             not null, primary key
#  granted_post_type_ids  :uuid             default([]), not null, is an Array
#  recipient_phone_number :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  recipient_id           :uuid
#  world_id               :uuid             not null
#
# Indexes
#
#  index_world_invitations_on_recipient_id  (recipient_id)
#  index_world_invitations_on_world_id      (world_id)
#  index_world_invitations_uniqueness       (world_id,recipient_phone_number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (recipient_id => users.id)
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WorldInvitation < ApplicationRecord
  include NormalizesPhoneNumber
  include Noticeable

  # == Associations ==

  belongs_to :world
  has_one :world_owner, through: :world, source: :owner
  has_many :world_key_recipients, through: :world, source: :key_recipients
  has_many :world_post_types, through: :world, source: :post_types

  belongs_to :recipient, class_name: "User", optional: true
  has_one :world_key,
    inverse_of: :invitation,
    foreign_key: :invitation_id,
    dependent: :destroy

  sig { returns(World) }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing world"
  end

  sig { returns(User) }
  def world_owner!
    world_owner or raise ActiveRecord::RecordNotFound, "Missing world owner"
  end

  sig { returns(User) }
  def recipient!
    recipient or raise ActiveRecord::RecordNotFound, "Missing recipient"
  end

  # == Normalizations ==

  normalizes_phone_number :recipient_phone_number
  normalizes :granted_post_type_ids, with: ->(ids) { ids.compact }

  # == Validations ==

  validates :recipient_phone_number,
    presence: true,
    uniqueness: { scope: :world, message: "already invited" },
    phone: { possible: true, types: :mobile, extensions: false }
  validates :granted_post_type_ids, presence: { message: "select at least one" }
  validate :validate_recipient_not_world_owner
  validate :validate_recipient_not_world_key_recipient

  # == Scopes ==

  scope :pending_acceptance, -> { where.missing(:world_key) }
  scope :accepted, -> { where.associated(:world_key) }

  # == Hooks ==

  after_initialize :set_recipient_phone_number, unless: :recipient_phone_number?
  after_create_commit :create_notifications_for_recipient!, if: :recipient_id?

  # == Notifications ==

  sig { override.params(recipient: User).returns(Notification::Message) }
  def notification_message(recipient:)
    world = world!
    world_owner = world_owner!
    Notification::Message.new(
      target_url: :home,
      title: "you're invited to #{world.name}!",
      body: "#{world_owner.name} invited you to join their world",
      world:,
    )
  end

  # == World Keys ==

  sig { returns(String) }
  def world_key_grant_message
    WorldKey.grant_verifier.generate({
      world_id:,
      post_type_ids: granted_post_type_ids,
    })
  end

  # == Methods ==

  sig { returns(PostType::PrivateAssociationRelation) }
  def granted_post_types
    world_post_types.where(id: granted_post_type_ids)
  end

  private

  # == Callbacks ==

  sig { void }
  def create_notifications_for_recipient!
    if (recipient = self.recipient)
      notifications.create!(recipient:)
    end
  end

  sig { void }
  def set_recipient_phone_number
    if (recipient = self.recipient)
      self.recipient_phone_number = recipient.phone_number
    end
  end

  sig { void }
  def validate_recipient_not_world_owner
    if (recipient_id = self.recipient_id) && recipient_id == world!.owner_id
      errors.add(:recipient, "cannot be the world owner")
    elsif recipient_phone_number == world_owner!.phone_number
      errors.add(:recipient_phone_number, "cannot be the world owner")
    end
  end

  sig { void }
  def validate_recipient_not_world_key_recipient
    if (recipient_id = self.recipient_id) && world_key_recipients.exists?(id: recipient_id)
      errors.add(:recipient, "already joined")
    elsif world_key_recipients.exists?(phone_number: recipient_phone_number)
      errors.add(:recipient_phone_number, "already joined")
    end
  end
end
