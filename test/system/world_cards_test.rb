# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class WorldsCardsTest < ApplicationSystemTestCase
  test "add card to wallet button downloads a valid pkpass" do
    world = worlds(:sues_world)
    card = world.cards.create!(granted_key_color: :blue)

    visit world_card_path(card)
    click_on "add card to wallet"

    pass_path = assert_download("*.pkpass", wait: 10)
    Rails.logger.info("Pass downloaded successfully: #{pass_path}")

    # This is a web tool that validates .pkpass files
    visit("https://pkpassvalidator.azurewebsites.net:443")
    attach_file("passFile", pass_path)
    click_button "Validate"
    assert_text("Validation Results:", wait: 10)
    assert_no_selector(".thumbs.down.icon")
  end
end
