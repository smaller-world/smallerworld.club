# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = T.let(users(:bob), User)
    @world = T.let(worlds(:bobs_world_one), World)
  end

  test "owner creates a world" do
    sign_in_as(@owner)

    assert_difference -> { @owner.owned_worlds.count }, 1 do
      post worlds_path, params: {
        world: {
          name: "Fresh World",
          blurb: "a new place",
          icon: fixture_file_upload("world_icon.png", "image/png"),
        },
      }
    end

    world = @owner.owned_worlds.chronological.last
    assert_redirected_to world_path(world)
  end

  test "owner views their world feed" do
    create_post(world: @world, body: "first post")

    sign_in_as(@owner)

    get world_path(@world)
    assert_response :success
  end

  test "owner updates a world" do
    sign_in_as(@owner)

    patch world_path(@world),
      params: {
        world: {
          blurb: "updated blurb",
        },
      }
    assert_redirected_to world_path(@world)

    @world.reload
    assert_equal "updated blurb", @world.blurb
  end

  test "unauthenticated visitor is redirected to sign in" do
    get world_path(@world)
    assert_redirected_to new_session_path
  end

  test "unauthenticated visitor cannot reach the new world form" do
    get new_world_path
    assert_redirected_to new_session_path
  end

  test "a friend leaves a world" do
    friend = users(:sue)
    grant_key(world: @world, recipient: friend, color: :blue)

    sign_in_as(friend)

    assert_difference -> { @world.keys.where(recipient: friend).count }, -1 do
      post leave_world_path(@world)
    end
    assert_redirected_to home_path
  end
end
