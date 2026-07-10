# typed: true
# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated visitor is redirected to sign in" do
    get home_path
    assert_redirected_to new_session_path
  end
end
