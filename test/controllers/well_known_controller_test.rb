# typed: true
# frozen_string_literal: true

require "test_helper"

class WellKnownControllerTest < ActionDispatch::IntegrationTest
  test "serves the apple-app-site-association file" do
    get apple_app_site_association_path
    assert_response :success
    assert_equal "application/json", response.content_type
  end
end
