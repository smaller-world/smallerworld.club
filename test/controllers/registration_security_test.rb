# typed: strict
# frozen_string_literal: true

require "test_helper"
require "timeout"

class RegistrationSecurityTest < ActionDispatch::IntegrationTest
  test "a completed registration cookie cannot recreate an account after deletion" do
    verification_request = begin_registration
    registration_cookie = cookies[session_cookie_key]
    register_account
    assert_redirected_to home_url
    user = User.find_by!(phone_number: verification_request.phone_number)
    registration = Registration.find_by!(phone_number_verification_request: verification_request)
    assert_equal user, registration.created_user
    assert_predicate registration, :completed_at?

    delete account_path
    assert_redirected_to root_path
    assert_not User.exists?(user.id)
    assert_nil registration.reload.created_user_id
    assert_predicate registration, :completed_at?
    get home_path
    assert_redirected_to new_session_path

    # Replay the genuine cookie issued before registration completed.
    # Clearing the token from the latest browser cookie cannot revoke this copy.
    cookies[session_cookie_key] = registration_cookie
    assert_registration_rejected
  end

  test "an unfinished registration remains usable after a week" do
    begin_registration
    registration_cookie = cookies[session_cookie_key]

    travel 1.week do
      cookies[session_cookie_key] = registration_cookie
      assert_difference -> { User.count }, 1 do
        register_account
      end
      assert_redirected_to home_url
      get home_path
      assert_response :success
    end
  end

  test "invalid account details leave registration available for a corrected submission" do
    verification_request = begin_registration
    registration = Registration.find_by!(phone_number_verification_request: verification_request)

    assert_no_difference([ -> { User.count }, -> { Session.count } ]) do
      post account_path, params: {
        user: { name: "", unconfirmed_email_address: "bobby@example.com", time_zone_name: "America/Toronto" },
      }
    end
    assert_response :unprocessable_content
    assert_nil registration.reload.completed_at
    assert_nil registration.created_user_id

    register_account
    assert_redirected_to home_url
    assert_predicate registration.reload, :completed_at?
  end

  test "concurrent registration submissions create only one account and session" do
    begin_registration
    registration_cookie = cookies[session_cookie_key]
    clients = [ open_session, open_session ]
    clients.each { |client| client.cookies[session_cookie_key] = registration_cookie }
    ready = Queue.new
    proceed = Queue.new
    find = Registration.method(:find_by_token_for)
    threads = T.let([], T::Array[Thread])

    # Both clients resolve valid proof before either completes registration.
    synchronized_find = lambda do |*args|
      record = find.call(*args)
      ready << true
      proceed.pop
      record
    end

    assert_difference([ -> { User.count }, -> { Session.count } ], 1) do
      Registration.stub(:find_by_token_for, synchronized_find) do
        threads = clients.map do |client|
          Thread.new do
            client.post account_path, params: {
              user: { name: "bobby", unconfirmed_email_address: "bobby@example.com", time_zone_name: "America/Toronto" },
            }
          end
        end

        Timeout.timeout(10) do
          clients.each { ready.pop }
          clients.each { proceed << true }
          threads.each(&:value)
        end
      ensure
        threads.each { |thread| thread.kill if thread.alive? }
        threads.each(&:join)
      end
    end

    assert_equal 1, clients.count { |client| client.cookies[:session_id].present? }
    assert_equal 1, clients.count { |client| client.response.location == home_url }
    assert_equal 1, clients.count { |client| client.response.location == new_session_url }
  end

  test "pending registration proof cannot be used after signing in and out" do
    begin_registration
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest
      .create_test_mock_for!(user, verified: false)
    post verify_phone_number_verification_request_path(verification_request),
      params: {
        phone_number_verification_request: {
          verification_code: verification_request.verification_code,
          phone_number_owner: { time_zone_name: user.time_zone_name },
        },
      },
      as: :turbo_stream
    assert_redirected_to home_url

    delete session_path
    assert_redirected_to root_path

    assert_registration_rejected
  end

  test "a deleted account session cookie cannot authenticate again" do
    verification_request = begin_registration
    register_account
    assert_redirected_to home_url
    user = User.find_by!(phone_number: verification_request.phone_number)
    session_cookie = cookies[:session_id]

    delete account_path
    assert_redirected_to root_path
    assert_not User.exists?(user.id)

    cookies[:session_id] = session_cookie
    get home_path
    assert_redirected_to new_session_path
  end

  private

  # == Helpers ==

  sig { returns(PhoneNumberVerificationRequest) }
  def begin_registration
    # Start at the verification endpoint: no external Turnstile call is needed
    # to exercise registration token issuance and consumption through real HTTP.
    verification_request = PhoneNumberVerificationRequest.create!(
      phone_number: "+14165551234",
      ip_address: "127.0.0.1",
      user_agent: "test",
    )
    post verify_phone_number_verification_request_path(verification_request),
      params: {
        phone_number_verification_request: {
          verification_code: verification_request.verification_code,
        },
      },
      as: :turbo_stream
    assert_redirected_to(new_account_path)
    verification_request
  end

  sig { returns(String) }
  def session_cookie_key
    Rails.application.config.session_options.fetch(:key)
  end

  sig { void }
  def register_account
    post account_path, params: {
      user: {
        name: "bobby",
        unconfirmed_email_address: "bobby@example.com",
        time_zone_name: "America/Toronto",
      },
    }
  end

  sig { void }
  def assert_registration_rejected
    assert_no_difference([ -> { User.count }, -> { Session.count } ]) do
      register_account
    end
    assert_redirected_to(new_session_path)

    get(home_path)
    assert_redirected_to(new_session_path)
  end
end
