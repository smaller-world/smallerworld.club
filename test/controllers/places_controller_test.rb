# typed: strict
# frozen_string_literal: true

require "test_helper"

class PlacesControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated visitor is redirected to sign in" do
    get places_dock_path
    assert_redirected_to new_session_path
  end

  test "authenticated visitor sees the dock" do
    sign_in_as(users(:bob))

    get places_dock_path

    assert_response :success
    assert_select "title", "the dock | #{SmallerWorld.application.site_name}"
    assert_select "[data-slot=navigation].max-w-lg a[href=?]", home_path
    assert_select "[data-slot=page-container].max-w-lg video.w-full.h-auto[autoplay][muted][loop][playsinline][aria-hidden=true]" do
      assert_select "source[type='video/quicktime'][src*='dock-background']"
      assert_select "source[type='video/webm'][src*='dock-background']"
    end
  end
end
