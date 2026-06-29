# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeysControllerTest < ActionDispatch::IntegrationTest
  test "owner revokes a member's key" do
    world = worlds(:bobs_world_two)
    owner = world.owner!
    friend = users(:sue)
    key = world.keys.create!(recipient: friend)

    sign_in_as(owner)

    assert_difference -> { world.keys.count }, -1 do
      delete world_key_path(key)
    end
    assert_redirected_to world_keys_path(world)
  end
end
