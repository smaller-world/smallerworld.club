# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "a new phone number completes onboarding into a new account" do
    phone = Phonelib.parse("+14165551234")

    visit new_session_path

    fill_in :phone_number_verification_request_phone_number, with: phone.national
    find('input[name="cf-turnstile-response"]', visible: false, wait: 10)
      .execute_script('this.value = "XXXX.DUMMY.TOKEN.XXXX"')
    click_button "send verification code"

    assert_field "verification code", wait: 10

    verification_request = PhoneNumberVerificationRequest.chronological.last!
    fill_in "verification code", with: verification_request.verification_code
    click_button "complete login"

    assert_current_path new_account_path, wait: 10

    fill_in "your name", with: "bobby"
    fill_in "your email", with: "bobbysue@example.ca"
    click_button "create account"

    assert_current_path home_path, wait: 10
  end
end
