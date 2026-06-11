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
    @world = T.let(worlds(:bobs_world_one), World)
    @grant = T.let(@world.key_grant(color: :blue), String)
  end

  # == Tests ==

  test "an iOS browser is issued a card and redirected to it" do
    assert_difference -> { @world.cards.count }, 1 do
      get world_key_grant_path(@grant),
        headers: {
          "User-Agent" => IOS_USER_AGENT,
        }
    end
    card = @world.cards.chronological.last!
    assert_equal "blue", card.granted_key_color
    assert_redirected_to world_card_path(card)
  end

  test "a Hotwire Native iOS app renders the grant page" do
    assert_no_difference -> { @world.cards.count } do
      get world_key_grant_path(@grant),
        headers: {
          "User-Agent" => HOTWIRE_NATIVE_IOS_USER_AGENT,
        }
    end
    assert_response :success
  end

  test "non-iOS browsers render the grant page" do
    assert_no_difference -> { @world.cards.count } do
      get world_key_grant_path(@grant)
    end
    assert_response :success
  end

  test "accepting a key grant adds the recipient to the world" do
    recipient = users(:sue)
    recipients_device = devices(:sues_phone)

    sign_in_as(recipient, device: recipients_device)

    assert_difference -> { recipient.world_keys.count }, 1 do
      post accept_world_key_grant_path(@grant)
    end
    assert_redirected_to world_path(@world, celebrate: true)

    key = recipient.world_keys.find_by!(world: @world)
    assert_equal "blue", key.color
    assert_predicate key.accepted_at, :present?
  end
end
