# typed: true
# frozen_string_literal: true

require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "a new phone number completes onboarding into a new account" do
    phone_number = "+14165551234"

    get edit_account_path
    assert_redirected_to new_session_path
    request = complete_phone_verification_for(phone_number:)
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
    assert_redirected_to edit_account_url
    assert_equal 1, user.sessions.count
    assert_predicate request.reload, :consumed_at?
    assert_predicate cookies[:session_id], :present?
  end

  test "registration permission cannot be reused after completion sign out or account deletion" do
    request = complete_phone_verification_for(phone_number: "+14165551234")
    token = session[:phone_number_verification_token]
    retained_browser_cookie = cookies[Rails.application.config.session_options[:key]]
    assert_no_difference -> { Session.count } do
      post verify_phone_number_verification_request_path(request),
        params: { phone_number_verification_request: { verification_code: request.verification_code } },
        as: :turbo_stream
    end
    assert_response :unprocessable_content
    assert_equal token, session[:phone_number_verification_token]

    assert_difference -> { Session.count }, 1 do
      post account_path, params: { user: registration_attributes }
    end
    assert_redirected_to home_url
    assert_nil session[:phone_number_verification_token]
    user = User.find_by!(phone_number: request.phone_number)
    sign_out
    [ false, true ].each do |delete_account|
      user.destroy! if delete_account
      cookies[Rails.application.config.session_options[:key]] = retained_browser_cookie
      assert_no_difference [ -> { User.count }, -> { Session.count } ] do
        post account_path, params: { user: registration_attributes }
      end
      assert_redirected_to new_session_path
      assert_nil cookies[:session_id]
    end
  end

  test "invalid registration renders account errors and keeps permission retryable beyond sms expiry" do
    request = complete_phone_verification_for(phone_number: "+14165551234")
    assert_no_difference [ -> { User.count }, -> { Session.count } ] do
      post account_path, params: { user: registration_attributes.merge(name: "") }
    end
    assert_response :unprocessable_content
    assert_includes response.body, "name"
    assert session[:phone_number_verification_token]
    assert_nil cookies[:session_id]
    assert_nil request.reload.consumed_at
    travel 10.minutes do
      assert_difference -> { Session.count }, 1 do
        post account_path, params: { user: registration_attributes }
      end
    end
    assert_redirected_to home_url
  end

  private

  def registration_attributes
    { name: "new friend", unconfirmed_email_address: "friend@example.com", time_zone_name: "America/Toronto" }
  end
end
