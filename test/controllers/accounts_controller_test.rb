# typed: true
# frozen_string_literal: true

require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "a new phone number completes onboarding into a new account" do
    phone_number = "+14165551234"

    complete_phone_verification_for(phone_number:)
    assert_redirected_to new_account_path
    assert_difference -> { User.count }, 1 do
      post account_path, params: {
        user: {
          name: "bobby",
          unconfirmed_email_address: "bobbysue@example.com",
          time_zone_name: "America/New_York",
        },
      }
    end

    user = User.find_by!(phone_number:)
    assert_equal "bobby", user.name
    assert_redirected_to home_url
    assert_predicate cookies[:session_id], :present?
  end
end
