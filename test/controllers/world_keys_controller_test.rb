# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @world = worlds(:bobs_world_two)
    @owner = @world.owner!
    @member = users(:sue)
    @world_key = @world.keys.create!(recipient: @member)
  end

  test "owner revokes a member's key and is redirected to world keys" do
    sign_in_as(@owner)

    assert_difference -> { @world.keys.count }, -1 do
      delete world_key_path(@world_key)
    end
    assert_redirected_to world_keys_path(@world)
  end

  test "member deletes their own key and is redirected to home" do
    sign_in_as(@member)
    assert_difference -> { @world.keys.count }, -1 do
      delete world_key_path(@world_key)
    end
    assert_redirected_to home_path
  end
end
