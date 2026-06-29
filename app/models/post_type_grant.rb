# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: post_type_grants
#
#  id           :uuid             not null, primary key
#  created_at   :timestamptz      not null
#  post_type_id :uuid             not null
#  world_key_id :uuid             not null
#
# Indexes
#
#  index_post_type_grants_on_post_type_id  (post_type_id)
#  index_post_type_grants_on_world_key_id  (world_key_id)
#  index_post_type_grants_uniqueness       (world_key_id,post_type_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (post_type_id => post_types.id)
#  fk_rails_...  (world_key_id => world_keys.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class PostTypeGrant < ApplicationRecord
  # == Associations ==

  belongs_to :world_key
  has_one :world, through: :world_key
  has_many :world_post_types, through: :world, source: :post_types
  has_one :recipient, through: :world_key

  belongs_to :post_type

  # == Validations ==

  validates :post_type, uniqueness: {
    scope: :world_key,
    message: "post type already granted",
  }
end
