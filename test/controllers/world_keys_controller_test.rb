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

  test "clearing a key's grants hides previously visible posts from the member" do
    @world_key.granted_post_types << @world.post_types.create!(label: "journal entry")
    create_post(world: @world, body: "journal post shared with the member")
    member = open_session { |client| client.sign_in_as(@member) }
    feed_path = world_posts_path(@world)
    headers = { "Turbo-Frame" => "posts" }

    member.get(feed_path, headers:)
    member.assert_response(:success)
    assert_includes member.response.body, "journal post shared with the member"

    sign_in_as(@owner)
    patch world_key_path(@world_key), params: { world_key: { granted_post_type_ids: [ "" ] } }
    assert_redirected_to world_keys_path(@world)

    member.get(feed_path, headers:)
    member.assert_response(:success)
    assert_not_includes member.response.body, "journal post shared with the member"
  end

  test "a member cannot add a post type to their own key" do
    journal_type = @world.post_types.create!(label: "journal entry")
    diary_type = @world.post_types.create!(label: "diary")
    @world_key.granted_post_types << journal_type
    sign_in_as(@member)

    patch world_key_path(@world_key), params: {
      world_key: { granted_post_type_ids: [ journal_type.id, diary_type.id ] },
    }

    assert_response :forbidden
    assert_equal [ journal_type.id ], @world_key.reload.granted_post_type_ids
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
