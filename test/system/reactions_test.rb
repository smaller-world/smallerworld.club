# typed: strict
# frozen_string_literal: true

require "application_system_test_case"

class ReactionsTest < ApplicationSystemTestCase
  test "adding a reaction updates the post without a full reload" do
    owner = users(:bob)
    friend = users(:sue)
    world = create_world(owner:, name: "Live React World")
    key_type = WorldKeyType.create!(world:, name: "close friends", color: "pink")
    world.keys.create!(recipient: friend, type_id: key_type.id)
    create_post(world:, body: "react to me", visible_to_key_type_ids: [ key_type.id ])

    sign_in_as(friend)

    visit world_path(world)
    assert_text "react to me", wait: 10

    # Stamp the live window so we can detect a full page reload, which would
    # replace the document and reset this flag to undefined.
    page.execute_script("window.__noReload = true")

    # Open the emoji picker on the post under test.
    post_card = find(".post-card", text: "react to me", wait: 10)
    within(post_card) do
      click_button("new_post_reaction_dialog_trigger", wait: 10)
    end
    within("em-emoji-picker") do
      first('button[aria-label="😀"]', wait: 10).click
    end
    assert_no_selector("em-emoji-picker")

    within(post_card) do
      assert_text "😀", wait: 10
    end
    assert(
      page.evaluate_script("window.__noReload === true"),
      "expected the reaction to update the post without a full page reload",
    )
  end
end
