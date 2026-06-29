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
    @world = T.let(create_world(owner: users(:bob), name: "Grant World"), World)
    @grant = T.let(@world.key_grant, String)
  end

  # == Tests ==

  test "accepting a key grant adds the recipient to the world" do
    recipient = users(:sue)
    recipients_device = devices(:sues_phone)

    sign_in_as(recipient, device: recipients_device)

    assert_difference -> { recipient.world_keys.count }, 1 do
      post accept_world_key_grant_path(@grant), as: :turbo_stream
    end
    assert_redirected_to world_path(@world, celebrate: true)
  end
end
