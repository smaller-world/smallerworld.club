# typed: true
# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated visitor is redirected to sign in" do
    get home_path
    assert_redirected_to new_session_path
  end

  test "redirects to the appstore listing when the app is required" do
    get home_path, params: { require_app: "1" }
    assert_redirected_to appstore_listing_path
  end
end
