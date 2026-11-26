# typed: strict
# frozen_string_literal: true

require "application_system_test_case"

class WorldsTest < ApplicationSystemTestCase
  test "a user creates their first world from home" do
    user = users(:jane)
    user.update!(email_address: "jane@example.com")
    world_name = "Jane's World"

    sign_in_as(user)
    assert_current_path home_path
    click_link "create your world"

    fill_in "world[name]", with: world_name
    attach_file "world_icon", file_fixture("world_icon.png"), make_visible: true
    click_button "crop and continue"
    find("input[name='world[icon]']", visible: false, wait: 10) { |input| input.value.present? }
    find(:button, text: /\Acreate /).click

    assert_selector "h1", text: world_name
    visit home_path
    assert_link world_name
    assert_no_link "create your world"
  end

  test "owner resumes a draft and creates the post" do
    owner = users(:bob)
    world = create_world(owner:, name: "Draft World")

    sign_in_as(owner)

    visit world_path(world)
    click_button "new post"
    click_link "journal entry"

    clock = page.driver.with_playwright_page(&:clock)
    time = Time.current
    clock.set_fixed_time(time.iso8601)
    saved_text = /\Adraft saved at /

    fill_in "post[title]", with: "a draft title"
    find("input[name='post[emoji]']").click
    title_save = find("p", text: saved_text, wait: 10).text

    clock.set_fixed_time((time + 1.minute).iso8601)
    within("em-emoji-picker") do
      first('button[aria-label="😀"]', wait: 10).click
    end
    assert_field "post[emoji]", with: "😀"
    emoji_save = find("p", text: saved_text, wait: 10) { |label| label.text != title_save }.text

    body = "a draft body"
    editor = find("lexxy-editor [contenteditable='true']")
    editor.click
    clock.set_fixed_time((time + 2.minutes).iso8601)
    editor.set(body)
    assert_selector("p", text: saved_text, wait: 10) { |label| label.text != emoji_save }

    visit world_path(world)
    click_button "new post"
    click_button "continue from draft?"

    within("form[action='#{world_posts_path(world)}']", wait: 10) do
      assert_field "post[title]", with: "a draft title"
      assert_field "post[emoji]", with: "😀"
      assert_selector "lexxy-editor[name='post[body]'] [contenteditable='true']",
        text: body
      click_button "submit post"
    end

    assert_current_path world_path(world), ignore_query: true
    assert_text "a draft title"
    assert_text body
    assert_text "😀"
  end

  test "scrolling the feed loads more posts via turbo stream" do
    owner = users(:bob)
    world = create_world(owner:, name: "Scroll World")
    first_created_at = 1.hour.ago
    7.times do |i|
      create_post(world:, body: "post number #{i}", created_at: first_created_at + i.minutes)
    end

    sign_in_as(owner)
    current_window.resize_to(1024, 600)

    visit world_path(world)
    assert_text "post number 6"
    assert_no_text "post number 0", wait: 0

    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    assert_text "post number 0", wait: 10
    assert_text "post number 6"
  end
end
