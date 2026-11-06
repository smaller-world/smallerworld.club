# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeyGrantsControllerTest < ActionDispatch::IntegrationTest
  # == Configuration ==

  IOS_USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) " \
    "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 " \
    "Safari/604.1"
  HOTWIRE_NATIVE_IOS_USER_AGENT = "#{IOS_USER_AGENT} Hotwire Native iOS".freeze

  setup do
    @world = worlds(:bobs_world_one)
    @recipient = users(:sue)
    @grant_message = @world.key_grant_message(post_type_ids: @world.post_type_ids)
  end

  # == Tests ==

  test "viewing a key grant with an altered separator shows an invalid link page" do
    get world_key_grant_path(@grant_message.sub("--", "–"))

    assert_response :bad_request
    assert_select "title", "invalid key link | smaller world"
    assert_select "a[href=?]", home_path, count: 0
  end

  test "accepting an invalid key grant shows an invalid link page without granting access" do
    sign_in_as(@recipient)

    assert_no_difference [ -> { WorldKey.count }, -> { WorldInvitation.count } ] do
      post accept_world_key_grant_path("invalid"), as: :turbo_stream
    end

    assert_response :bad_request
    assert_equal "text/html", response.media_type
    assert_select "title", "invalid key link | smaller world"
    assert_select "a[href=?]", home_path, text: "back to your worlds"
  end

  test "accepting a key grant adds the recipient to the world" do
    sign_in_as(@recipient)

    assert_difference -> { @recipient.world_keys.count }, 1 do
      post accept_world_key_grant_path(@grant_message), as: :turbo_stream
    end
    assert_redirected_to world_path(@world)
  end
end
