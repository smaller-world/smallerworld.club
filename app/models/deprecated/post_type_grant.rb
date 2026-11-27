# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: deprecated_post_type_grants
#
#  id           :uuid             not null, primary key
#  created_at   :timestamptz      not null
#  post_type_id :uuid             not null
#  world_id     :uuid             not null
#  world_key_id :uuid             not null
#
# Indexes
#
#  index_deprecated_post_type_grants_on_post_type_id  (post_type_id)
#  index_deprecated_post_type_grants_on_world_key_id  (world_key_id)
#  index_post_type_grants_uniqueness                  (world_key_id,post_type_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  ([post_type_id, world_id] => post_types[id, world_id])
#  fk_rails_...  ([world_key_id, world_id] => world_keys[id, world_id])
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Deprecated::PostTypeGrant < ApplicationRecord
  # == Associations ==

  belongs_to :world_key
  belongs_to :post_type

  # == Validations ==

  validate :validate_post_type_world
  validates :post_type, uniqueness: {
    scope: :world_key,
    message: "post type already granted",
  }

  # == Hooks ==

  before_validation :set_world_id

  private

  sig { void }
  def set_world_id
    if (key = world_key)
      self.world_id = key.world_id
    end
  end

  sig { void }
  def validate_post_type_world
    if (type = post_type) && type.world_id != world_id
      errors.add(:post_type, "must belong to the same world as the key")
    end
  end
end
