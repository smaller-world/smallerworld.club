# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeyCardsControllerTest < ActionDispatch::IntegrationTest
  test "accepting a card's key grant claims it and adds recipient to the world" do
    world = worlds(:bobs_world_one)
    card = world.cards.create!(granted_key_color: :blue)
    recipient = users(:sue)
    recipients_device = devices(:sues_phone)

    sign_in_as(recipient, device: recipients_device)

    assert_difference -> { recipient.world_keys.count }, 1 do
      post accept_world_card_key_grant_path(card)
    end
    assert_redirected_to world_path(world, celebrate: true)

    card.reload
    assert_equal recipient, card.cardholder
    assert_equal recipients_device, card.device

    key = recipient.world_keys.find_by!(world:)
    assert_equal "blue", key.color
    assert_predicate key.accepted_at, :present?
  end

  test "claiming a card updates the card's cardholder and device" do
    world = worlds(:bobs_world_one)
    card = world.cards.create!(granted_key_color: :blue)
    recipient = users(:sue)
    recipients_device = devices(:sues_phone)

    sign_in_as(recipient, device: recipients_device)

    post claim_world_card_path(card)
    assert_redirected_to world_path(world)

    card.reload
    assert_equal recipient, card.cardholder
    assert_equal recipients_device, card.device
  end
end
