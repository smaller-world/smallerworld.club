# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class WorldKeyGrantsTest < ApplicationSystemTestCase
  setup do
    @world = worlds(:bobs_world_one)
    key_type = @world.key_types.create!(name: "close friends", color: "pink")
    @grant_message = WorldKey.grant_message(key_type_id: key_type.id)
  end

  # Regression: scanning the QR code / opening the invite link used to bounce
  # people to `root_url`. It must land on the world key grant show page.
  test "opening the invite link in the browser shows the phone number field" do
    visit world_key_grant_path(@grant_message)

    assert_text @world.name
    assert_field "world_invitation_recipient_phone_number"
  end

  test "accepting the invite while signed in opens the world and shows a granted post" do
    recipient = users(:sue)
    world = create_world(owner: users(:bob))
    body = "a journal entry for invited friends"
    key_type = world.key_types.create!(name: "close friends", color: "pink")
    create_post(world:, body:, visible_to_key_type_ids: [ key_type.id ])
    grant_message = WorldKey.grant_message(key_type_id: key_type.id)
    sign_in_as(recipient)

    visit world_key_grant_path(grant_message)

    assert_text world.name
    assert_no_field "world_invitation_recipient_phone_number"

    click_button "enter #{world.name}"

    assert_current_path world_path(world)
    assert_text body
  end

  test "a signed-out friend saves and redeems the key type selected by the owner" do
    owner = users(:bob)
    recipient = users(:sue)
    recipient.update!(email_address: "sue@example.com", email_address_confirmed_at: Time.current)
    world = create_world(owner:, name: "Phone Invitation World")
    shared_type = world.key_types.find_by!(name: "chosen family")
    other_type = world.key_types.find_by!(name: "new friends")
    create_post(world:, body: "an invitation-only poem", visible_to_key_type_ids: [ shared_type.id ])
    create_post(world:, body: "a post for other friends", visible_to_key_type_ids: [ other_type.id ])

    sign_in_as(owner)
    visit world_keys_path(world)
    click_link "give a key to a new friend"
    find("label", text: "chosen family").click
    link = find_button("copy invite link")["data-clipboard-copy-value"]

    Capybara.using_session(:invite_recipient) do
      visit link
      fill_in "world_invitation_recipient_phone_number", with: Phonelib.parse(recipient.phone_number).national
      click_button "save my invitation to my account!"
      assert_field "world_invitation_recipient_phone_number", disabled: true

      sign_in_as(recipient)
      click_link world.name
      click_button "enter #{world.name}"

      assert_current_path world_path(world)
      assert_text "an invitation-only poem"
      assert_no_text "a post for other friends"
    end
  end
end
