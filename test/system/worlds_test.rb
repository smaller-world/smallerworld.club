# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class WorldsTest < ApplicationSystemTestCase
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
