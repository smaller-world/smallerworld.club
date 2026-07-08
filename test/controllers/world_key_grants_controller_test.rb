# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeyGrantsControllerTest < ActionDispatch::IntegrationTest
  # == Configuration ==

  IOS_USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) " \
    "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 " \
    "Safari/604.1"
  HOTWIRE_NATIVE_IOS_USER_AGENT = "#{IOS_USER_AGENT} Hotwire Native iOS"

  setup do
    @owner = users(:bob)
    @world = create_world(owner: @owner, name: "Grant World")
    @grant_message = @world.key_grant_message(post_type_ids: @world.post_type_ids)
  end

  # == Tests ==

  test "accepting a key grant adds the recipient to the world" do
    recipient = users(:sue)
    sign_in_as(recipient)

    assert_difference -> { recipient.world_keys.count }, 1 do
      post accept_world_key_grant_path(@grant_message), as: :turbo_stream
    end
    assert_redirected_to world_path(@world)
  end
end
