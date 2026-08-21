# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class WorldsTest < ApplicationSystemTestCase
  test "owner resumes a draft and creates the post" do
    owner = users(:bob)
    world = create_world(owner:, name: "Draft World")

    sign_in_as(owner)

    visit world_path(world)
    click_button "new post"
    click_link "journal entry"

    fill_in "post[title]", with: "a draft title"
    find("input[name='post[emoji]']").click
    within("em-emoji-picker") do
      first('button[aria-label="😀"]', wait: 10).click
    end
    assert_field "post[emoji]", with: "😀"
    assert_selector "[data-post-draft-target='savedTimestampLabel'][data-fade]",
      wait: 10
    body = "a draft body"
    find("lexxy-editor [contenteditable='true']").send_keys(body)
    assert_no_selector "[data-post-draft-target='savedTimestampLabel'][data-fade]",
      wait: 10

    visit world_path(world)
    click_button "new post"
    click_button "continue from draft?"

    assert_selector "form[data-post-draft-restoring-value]", wait: 10
    assert_no_selector "form[data-post-draft-restoring-value]", wait: 10
    assert_field "post[title]", with: "a draft title"
    assert_field "post[emoji]", with: "😀"
    assert_selector "lexxy-editor[name='post[body]'] [contenteditable='true']",
      text: body

    click_button "submit post"

    assert_current_path world_path(world), ignore_query: true
    assert_text "a draft title"
    assert_text body
    assert_text "😀"
  end

  test "scrolling the feed loads more posts via turbo stream" do
    owner = users(:bob)
    world = create_world(owner:, name: "Scroll World")
    7.times do |i|
      create_post(world:, body: "post number #{i}")
    end

    sign_in_as(owner)

    visit world_path(world)
    assert_text "post number 0"

    # The feed paginates at 5; later posts load on scroll.
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    assert_text "post number 6", wait: 10
  end
end
