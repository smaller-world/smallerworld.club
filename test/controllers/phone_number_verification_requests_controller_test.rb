# typed: true
# frozen_string_literal: true

require "test_helper"
require "timeout"

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

    assert_difference -> { user.sessions.count }, 1 do
      verify_request(verification_request, code: verification_request.verification_code)
    end
    assert_redirected_to home_url
    assert_predicate cookies[:session_id], :present?
    assert_predicate verification_request.reload, :verified?
    assert_equal "America/Los_Angeles", user.reload.time_zone_name
    assert_equal verification_request, user.sessions.order(:created_at).last!.phone_number_verification_request
  end

  test "wrong code for a pending request does not sign in or update the user" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)

    assert_verification_rejected(user, verification_request, code: "wrong")
  end

  test "wrong code for a verified request does not sign in or update the user" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: true)

    assert_verification_rejected(user, verification_request, code: "wrong")
  end

  test "expired pending request does not sign in or update the user" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)

    travel PhoneNumberVerificationRequest::EXPIRATION_DURATION + 1.second do
      assert_verification_rejected(user, verification_request, code: verification_request.verification_code)
    end
  end

  test "expired verified request does not sign in or update the user" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: true)

    travel PhoneNumberVerificationRequest::EXPIRATION_DURATION + 1.second do
      assert_verification_rejected(user, verification_request, code: verification_request.verification_code)
    end
  end

  test "already verified request with the correct code does not sign in or update the user" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: true)

    assert_verification_rejected(user, verification_request, code: verification_request.verification_code)
  end

  test "a successful sign in cannot be replayed by another client" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)
    original_client = open_session
    original_client.post verify_phone_number_verification_request_path(verification_request),
      params: {
        phone_number_verification_request: {
          verification_code: verification_request.verification_code,
          phone_number_owner: { time_zone_name: user.time_zone_name },
        },
      },
      as: :turbo_stream
    original_client.assert_redirected_to(home_url)
    assert_equal 1, user.sessions.where(phone_number_verification_request: verification_request).count

    assert_verification_rejected(user, verification_request.reload, code: verification_request.verification_code)
  end

  test "concurrent verification attempts create only one session" do
    user = users(:bob)
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)
    clients = [ open_session, open_session ]
    ready = Queue.new
    proceed = Queue.new
    find = PhoneNumberVerificationRequest.method(:find)
    threads = T.let([], T::Array[Thread])

    # Both HTTP requests load the pending record before either can consume it.
    # No sleeps or mocked verification results: the real verification and session
    # creation run against the database, including any consumption locking.
    synchronized_find = lambda do |*args|
      record = find.call(*args)
      ready << true
      proceed.pop
      record
    end

    assert_difference -> { user.sessions.count }, 1 do
      PhoneNumberVerificationRequest.stub(:find, synchronized_find) do
        threads = clients.map do |client|
          Thread.new do
            client.post verify_phone_number_verification_request_path(verification_request),
              params: {
                phone_number_verification_request: {
                  verification_code: verification_request.verification_code,
                  phone_number_owner: { time_zone_name: user.time_zone_name },
                },
              },
              as: :turbo_stream
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

    assert_equal 1, clients.count { |client| client.response.redirect? }
    assert_equal 1, clients.count { |client| client.cookies[:session_id].present? }
  end

  private

  sig { params(verification_request: PhoneNumberVerificationRequest, code: String).void }
  def verify_request(verification_request, code:)
    post verify_phone_number_verification_request_path(verification_request),
      params: {
        phone_number_verification_request: {
          verification_code: code,
          phone_number_owner: { time_zone_name: "America/Los_Angeles" },
        },
      },
      as: :turbo_stream
  end

  sig { params(user: User, verification_request: PhoneNumberVerificationRequest, code: String).void }
  def assert_verification_rejected(user, verification_request, code:)
    assert_no_changes(-> { user.reload.attributes }) do
      assert_no_changes(-> { verification_request.reload.verified_at }) do
        assert_no_difference(-> { user.sessions.count }) do
          verify_request(verification_request, code:)
        end
      end
    end

    assert_response(:success)
    assert_equal("text/vnd.turbo-stream.html", response.media_type)
    assert_select('turbo-stream[action="replace"][target="phone_number_verification_form"]')
    assert_nil(cookies[:session_id])
  end
end
