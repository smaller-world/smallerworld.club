# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @world = worlds(:bobs_world_two)
  end

  test "owner revokes a member's key" do
    owner = @world.owner!
    friend = users(:sue)
    key = @world.keys.create!(recipient: friend)

    sign_in_as(owner)

    assert_difference -> { @world.keys.count }, -1 do
      delete world_key_path(key)
    end
    assert_redirected_to world_keys_path(@world)
  end

  test "a friend deletes their own key" do
    friend = users(:sue)
    key = @world.keys.create!(recipient: friend)

    sign_in_as(friend)

    assert_difference -> { @world.keys.where(recipient: friend).count }, -1 do
      delete world_key_path(key)
    end
    assert_redirected_to home_path
  end
end
