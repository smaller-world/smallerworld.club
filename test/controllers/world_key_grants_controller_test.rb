# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeyGrantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @world = worlds(:bobs_world_one)
    @recipient = users(:sue)
    @key_type = @world.key_types.create!(name: "close friends", color: "pink")
    @grant_message = WorldKey.grant_message(key_type_id: @key_type.id)
  end

  # == Tests ==

  test "viewing a key grant with an altered separator shows an invalid link page" do
    get world_key_grant_path(@grant_message.sub("--", "–"))

    assert_response :bad_request
    assert_select "main", text: /\binvalid\b/i
  end

  test "accepting an invalid key grant shows an invalid link page without granting access" do
    sign_in_as(@recipient)

    assert_no_difference [ -> { WorldKey.count }, -> { WorldInvitation.count } ] do
      post accept_world_key_grant_path("invalid"), as: :turbo_stream
    end

    assert_response :bad_request
    assert_equal "text/html", response.media_type
    assert_select "main", text: /\binvalid\b/i
  end

  test "accepting a key grant gives the recipient access to posts shared with its key type" do
    @world.post_types.create!(name: "journal entry")
    other_type = @world.key_types.create!(name: "new friends", color: "green")
    create_post(world: @world, body: "shared by invitation", visible_to_key_type_ids: [ @key_type.id ])
    create_post(world: @world, body: "outside the invitation", visible_to_key_type_ids: [ other_type.id ])
    sign_in_as(@recipient)

    assert_difference -> { @recipient.world_keys.count }, 1 do
      post accept_world_key_grant_path(@grant_message), as: :turbo_stream
    end
    assert_redirected_to world_path(@world)

    get world_posts_path(@world), headers: { "Turbo-Frame" => "posts" }
    assert_response :success
    assert_includes response.body, "shared by invitation"
    assert_not_includes response.body, "outside the invitation"
  end
end
