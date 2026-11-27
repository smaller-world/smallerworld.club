# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: world_key_types
#
#  id         :uuid             not null, primary key
#  color      :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  world_id   :uuid             not null
#
# Indexes
#
#  index_world_key_types_on_world_id_and_id    (world_id,id) UNIQUE
#  index_world_key_types_on_world_id_and_name  (world_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WorldKeyType < ApplicationRecord
  # == Attributes ==

  enumerize :color, in: [ :green, :orange, :pink, :blue ]

  # == Associations ==

  belongs_to :world
  has_many :keys, class_name: "WorldKey", foreign_key: :type_id, inverse_of: :type # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :invitations,
    class_name: "WorldInvitation",
    foreign_key: :key_type_id,
    inverse_of: :key_type,
    dependent: :destroy

  sig { returns(World) }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing associated world"
  end

  # == Validations ==

  validates :color, presence: true

  # == Hooks ==

  before_destroy :ensure_unused, prepend: true
  after_destroy :remove_from_post_audiences

  # == Scopes ==
  scope :alphabetical, -> () {
    order(:name)
  }

  # == Default Types ==

  sig { returns(WorldKeyType) }
  def self.chosen_family_type = new(name: "chosen family", color: "pink")

  sig { returns(WorldKeyType) }
  def self.new_friends_type = new(name: "new friends", color: "green")

  sig { returns(WorldKeyType) }
  def self.acquaintances_type = new(name: "acquaintances", color: "blue")

  sig { returns(T::Array[WorldKeyType]) }
  def self.default_types
    [ chosen_family_type, new_friends_type, acquaintances_type ]
  end

  sig { returns(WorldKeyType) }
  def self.existing_friends_type = new(name: "existing friends", color: "orange")

  private

  # == Callbacks ==

  sig { void }
  def ensure_unused
    # Prevent new keys or invitations from referencing the type during deletion.
    WorldKeyType.where(id:).lock.pick(:id)

    errors.delete(:base, :active_keys)
    errors.delete(:base, :pending_invitations)
    active_keys = keys.exists?
    pending_invitations = invitations.pending_acceptance.exists?
    errors.add(:base, :active_keys, message: "friends still have this key type") if active_keys
    if pending_invitations
      errors.add(:base, :pending_invitations, message: "pending invitations still use this key type")
    end
    throw :abort if active_keys || pending_invitations
  end

  sig { void }
  def remove_from_post_audiences
    Post.where(world_id:)
      .where("? = ANY(visible_to_key_type_ids)", id)
      .update_all([ "visible_to_key_type_ids = array_remove(visible_to_key_type_ids, ?::uuid)", id ]) # rubocop:disable Rails/SkipsModelValidations
  end
end
