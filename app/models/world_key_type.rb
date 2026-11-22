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
  # == Associations ==
  belongs_to :world
end
