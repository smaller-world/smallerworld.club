# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @world = worlds(:bobs_world_two)
    @owner = @world.owner!
    @member = users(:sue)
    @world_key = create_member_key(world: @world, recipient: @member)
  end

  test "only the owner can change which key type controls a friend's feed" do
    @world.post_types.create!(name: "journal entry")
    new_type = @world.key_types.create!(name: "chosen family", color: "pink")
    create_post(world: @world, body: "for new friends", visible_to_key_type_ids: [ @world_key.type_id ])
    create_post(world: @world, body: "for chosen family", visible_to_key_type_ids: [ new_type.id ])
    member = open_session { |client| client.sign_in_as(@member) }
    key_path = world_key_path(@world_key)
    feed_path = world_posts_path(@world)
    headers = { "Turbo-Frame" => "posts" }
    params = { world_key: { type_id: new_type.id } }

    member.patch(key_path, params:)
    member.assert_response(:forbidden)
    member.get(feed_path, headers:)
    member.assert_response(:success)
    assert_includes member.response.body, "for new friends"
    assert_not_includes member.response.body, "for chosen family"

    sign_in_as(@owner)
    patch(key_path, params:)
    assert_redirected_to world_keys_path(@world)

    member.get(feed_path, headers:)
    member.assert_response(:success)
    assert_includes member.response.body, "for chosen family"
    assert_not_includes member.response.body, "for new friends"
  end

  test "deleting an old key type removes its accepted invitation and keeps the reclassified key" do
    world = create_world(owner: @owner)
    old_type = world.key_types.find_by!(name: "new friends")
    new_type = world.key_types.find_by!(name: "chosen family")
    invitation = world.invitations.create!(recipient: @member, key_type: old_type)
    key = world.keys.create!(recipient: @member, type: old_type, invitation:)
    post = create_post(world:, visible_to_key_type_ids: [ old_type.id, new_type.id ])
    sign_in_as(@owner)

    patch world_key_path(key), params: { world_key: { type_id: new_type.id } }
    assert_redirected_to world_keys_path(world)

    old_type.destroy!

    assert_not WorldInvitation.exists?(invitation.id)
    assert_equal new_type.id, key.reload.type_id
    assert_nil key.invitation_id
    assert_equal [ new_type.id ], post.reload.visible_to_key_type_ids
  end

  test "owner revokes a member's key and ends their feed access" do
    @world.post_types.create!(name: "journal entry")
    body = "journal post shared with the member"
    create_post(world: @world, body:, visible_to_key_type_ids: [ @world_key.type_id ])
    member = open_session { |client| client.sign_in_as(@member) }
    feed_path = world_posts_path(@world)
    headers = { "Turbo-Frame" => "posts" }

    member.get(feed_path, headers:)
    member.assert_response(:success)
    assert_includes member.response.body, body

    sign_in_as(@owner)
    assert_difference -> { @world.keys.count }, -1 do
      delete world_key_path(@world_key)
    end
    assert_redirected_to world_keys_path(@world)

    member.get(feed_path, headers:)
    member.assert_response(:forbidden)
    assert_not_includes member.response.body, body
  end

  test "member deletes their own key and is redirected to home" do
    sign_in_as(@member)
    assert_difference -> { @world.keys.count }, -1 do
      delete world_key_path(@world_key)
    end
    assert_redirected_to home_path
  end
end
