# typed: strict
# frozen_string_literal: true

require "test_helper"

class PostCardsControllerTest < ActionDispatch::IntegrationTest
  test "the post card is visible to a recipient and forbidden to a user without a key" do
    friend = users(:sue)
    world = create_world(owner: users(:bob))
    key = create_member_key(world:, recipient: friend)
    body = "Post shared through its card"
    shared_post = create_post(world:, body:, visible_to_key_type_ids: [ key.type_id ])
    card_path = post_card_path(shared_post)
    headers = { "Turbo-Frame" => ActionView::RecordIdentifier.dom_id(shared_post, :card) }

    sign_in_as(friend)
    get(card_path, headers:)
    assert_response :success
    assert_includes response.body, body

    sign_in_as(users(:jane))
    get(card_path, headers:)
    assert_response :forbidden
    assert_not_includes response.body, body
  end
end
