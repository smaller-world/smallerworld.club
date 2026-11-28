# typed: true
# frozen_string_literal: true

require "test_helper"

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
class WorldKeyTypeTest < ActiveSupport::TestCase
  setup do
    @world = create_world(owner: users(:bob))
    @type = @world.key_types.find_by!(name: "new friends")
  end

  test "an active key blocks deletion of its type" do
    @world.keys.create!(recipient: users(:sue), type: @type)

    refute @type.destroy
    assert_predicate @type, :persisted?
    assert_equal [ :active_keys ], @type.errors.where(:base).map(&:type)
  end

  test "a pending invitation blocks deletion of its key type" do
    @world.invitations.create!(recipient: users(:sue), key_type: @type)

    refute @type.destroy
    assert_predicate @type, :persisted?
    assert_equal [ :pending_invitations ], @type.errors.where(:base).map(&:type)
  end

  test "deletion reports both active keys and pending invitations" do
    @world.keys.create!(recipient: users(:sue), type: @type)
    @world.invitations.create!(recipient: users(:jane), key_type: @type)

    refute @type.destroy
    assert_predicate @type, :persisted?
    assert_equal [ :active_keys, :pending_invitations ], @type.errors.where(:base).map(&:type)
  end
end
