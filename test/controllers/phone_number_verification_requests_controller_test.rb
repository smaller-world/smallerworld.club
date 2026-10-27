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

    get edit_account_path
    assert_redirected_to new_session_path
    post verify_phone_number_verification_request_path(verification_request),
      params: {
        phone_number_verification_request: {
          verification_code: verification_request.verification_code,
          phone_number_owner: {
            time_zone_name: "America/New_York",
          },
        },
      },
      as: :turbo_stream
    assert_redirected_to edit_account_url
    assert_predicate verification_request.reload, :consumed_at?
    assert_equal 1, user.sessions.count
    assert_predicate cookies[:session_id], :present?
    assert_predicate user.sessions, :exists?
  end
  test "a verified request with a wrong code cannot create another session" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: true)
    assert_no_difference -> { user.sessions.count } do
      post verify_phone_number_verification_request_path(verification_request),
        params: {
          phone_number_verification_request: {
            verification_code: "wrong",
            phone_number_owner: { time_zone_name: "America/New_York" },
          },
        },
        as: :turbo_stream
    end
    assert_response :unprocessable_content
    assert_nil cookies[:session_id]
  end

  test "wrong expired and repeated submissions fail without side effects in both flows" do
    [ :existing, :new_number ].product([ :wrong, :expired, :verified ]).each do |flow, failure|
      user = users(:bob)
      original_time_zone = user.time_zone_name
      phone_number = flow == :existing ? user.phone_number : "+14165551234"
      verification_request = PhoneNumberVerificationRequest.create!(
        phone_number:,
        user_agent: "test",
        ip_address: "127.0.0.1",
        verified_at: (Time.current if failure == :verified),
        created_at: (10.minutes.ago if failure == :expired),
      )
      assert_no_difference [ -> { Session.count }, -> { User.count } ] do
        post verify_phone_number_verification_request_path(verification_request),
          params: {
            phone_number_verification_request: {
              verification_code: (failure == :wrong ? "wrong" : verification_request.verification_code),
              phone_number_owner: { time_zone_name: "Europe/London" },
            },
          },
          as: :turbo_stream
      end
      assert_response :unprocessable_content
      assert_includes response.body, 'target="phone_number_verification_form"'
      assert_includes response.body, failure == :expired ? "has expired" : "is invalid"
      assert_nil cookies[:session_id]
      assert_nil session[:phone_number_verification_token]
      assert_equal original_time_zone, user.reload.time_zone_name
      assert_nil verification_request.reload.consumed_at
    end
  end

  test "correct code replay cannot mutate the owner after sign out" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)
    submit = ->(time_zone) do
      post verify_phone_number_verification_request_path(verification_request),
        params: {
          phone_number_verification_request: {
            verification_code: verification_request.verification_code,
            phone_number_owner: { time_zone_name: time_zone },
          },
        },
        as: :turbo_stream
    end
    assert_difference -> { Session.count }, 1 do
      submit.call("America/New_York")
    end
    assert_no_difference -> { Session.count } do
      submit.call("Europe/London")
    end
    assert_response :unprocessable_content
    assert_equal "America/New_York", user.reload.time_zone_name
    sign_out
    assert_no_difference -> { Session.count } do
      submit.call("Europe/London")
    end
    assert_response :unprocessable_content
    assert_equal "America/New_York", user.reload.time_zone_name
    assert_nil cookies[:session_id]
  end

  test "invalid owner time zone renders an actionable error and permits retry" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)
    post verify_phone_number_verification_request_path(verification_request),
      params: {
        phone_number_verification_request: {
          verification_code: verification_request.verification_code,
          phone_number_owner: { time_zone_name: "" },
        },
      },
      as: :turbo_stream
    assert_response :unprocessable_content
    assert_includes response.body, "time zone name"
    assert_nil verification_request.reload.verified_at
    assert_nil cookies[:session_id]
  end
end
