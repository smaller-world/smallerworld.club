# typed: true
# frozen_string_literal: true

require "test_helper"

class AppstoreListingsControllerTest < ActionDispatch::IntegrationTest
  test "redirects away to the TestFlight listing" do
    get appstore_listing_path
    assert_redirected_to Smallerworld.application.testflight_url
  end
end
