# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class ReactionsTest < ApplicationSystemTestCase
  test "adding a reaction updates the post without a full reload" do
    owner = users(:bob)
    friend = users(:sue)
    world = create_world(owner:, name: "Live React World")
    world.keys.create!(recipient: friend)
    create_post(world:, body: "react to me")

    sign_in_as(friend)

    visit world_path(world)
    assert_text "react to me", wait: 10

    # Stamp the live window so we can detect a full page reload, which would
    # replace the document and reset this flag to undefined.
    page.execute_script("window.__noReload = true")

    # Open the emoji picker and select fire.
    click_button("new_reaction_dialog_trigger", wait: 10)
    within("em-emoji-picker") do
      first('button[aria-label="😀"]', wait: 10).click
    end
    assert_no_selector("em-emoji-picker")

    assert_text "😀", wait: 10
    assert(
      page.evaluate_script("window.__noReload === true"),
      "expected the reaction to update the post without a full page reload",
    )
  end
end
