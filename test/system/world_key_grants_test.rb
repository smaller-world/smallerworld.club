# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class WorldKeyGrantsTest < ApplicationSystemTestCase
  setup do
    @world = worlds(:bobs_world_one)
    @grant_message = @world.key_grant_message(post_type_ids: @world.post_type_ids)
  end

  # Regression: scanning the QR code / opening the invite link used to bounce
  # people to `root_url`. It must land on the world key grant show page.
  test "opening the invite link in the browser shows the phone number field" do
    visit world_key_grant_path(@grant_message)

    assert_text "you've been invited to:"
    assert_text @world.name
    assert_selector "input[placeholder='your phone #']"
    assert_no_button "enter #{@world.name}"
  end

  test "opening the invite link while signed in shows the enter world button" do
    recipient = users(:sue)
    sign_in_as(recipient)

    visit world_key_grant_path(@grant_message)

    assert_text "you've been invited to:"
    assert_text @world.name
    assert_button "enter #{@world.name}"
    assert_no_selector "input[placeholder='your phone #']"
  end
end
