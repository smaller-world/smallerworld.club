# typed: true
# frozen_string_literal: true

require "test_helper"

class PhoneNumberVerificationRequestsControllerTest < ActionDispatch::IntegrationTest
  test "start new verification request" do
    assert_difference -> { PhoneNumberVerificationRequest.count }, 1 do
      post phone_number_verification_requests_path,
        headers: {
          "User-Agent" => "test",
        },
        params: {
          phone_number_verification_request: { phone_number: "+14165550000" },
          "cf-turnstile-response" => "dummy",
        },
        as: :turbo_stream
    end
    assert_response :success
  end

  test "sign in by verifying code" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest
      .create_test_mock_for!(user, verified: false)

    post verify_phone_number_verification_request_path(verification_request),
      params: {
        phone_number_verification_request: {
          verification_code: verification_request.verification_code,
        },
        user: {
          time_zone_name: "America/New_York",
        },
      },
      as: :turbo_stream
    assert_redirected_to home_url
    assert_predicate cookies[:session_id], :present?
    assert_predicate user.sessions, :exists?
  end
end
