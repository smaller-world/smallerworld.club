# typed: true
# frozen_string_literal: true

require "test_helper"

class PhoneNumberVerificationRequestTest < ActiveSupport::TestCase
  test "existing user submission consumes exactly once and survives session deletion" do
    user = users(:bob)
    request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)
    session = request.submit_code!(request.verification_code, time_zone_name: "America/New_York")
    assert_kind_of Session, session
    raise "expected a session" unless session.is_a?(Session)

    assert_predicate session, :persisted?
    assert_predicate request.reload, :consumed_at?
    assert_equal "America/New_York", user.reload.time_zone_name
    session.update!(updated_at: Time.current)
    session.destroy!
    assert_raises(ActiveRecord::RecordInvalid) do
      request.submit_code!(request.verification_code, time_zone_name: "Europe/London")
    end
    assert_equal "America/New_York", user.reload.time_zone_name
    assert_no_difference -> { Session.count } do
      assert_raises(ActiveRecord::RecordInvalid) do
        user.sessions.create!(phone_number_verification_request: request)
      end
    end
  end

  test "registration permission survives sms expiry but not consumption or account deletion" do
    request = new_request
    token = request.submit_code!(request.verification_code)
    assert_kind_of String, token
    assert_nil request.reload.consumed_at
    assert_raises(ActiveRecord::RecordInvalid) { request.submit_code!(request.verification_code) }
    travel 10.minutes do
      session = request.complete_registration!(registration_attributes.merge(phone_number: users(:bob).phone_number))
      assert_equal request.phone_number, session.user.phone_number
      assert_predicate session, :persisted?
      session.user.destroy!
      assert_nil PhoneNumberVerificationRequest.find_by_registration_token(token)
      assert_raises(ActiveRecord::RecordInvalid) { request.submit_code!(request.verification_code) }
      assert_raises(ActiveRecord::RecordInvalid) { request.complete_registration!(registration_attributes) }
    end
  end

  test "invalid owner attributes roll back verification and allow a retry" do
    user = users(:bob)
    request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)
    original_time_zone = user.time_zone_name
    assert_no_difference -> { Session.count } do
      error = assert_raises(ActiveRecord::RecordInvalid) do
        request.submit_code!(request.verification_code, time_zone_name: "invalid")
      end
      assert_kind_of User, error.record
      assert_predicate error.record.errors[:time_zone_name], :any?
    end
    assert_nil request.reload.verified_at
    assert_nil request.consumed_at
    assert_equal original_time_zone, user.reload.time_zone_name
    assert_kind_of Session, request.submit_code!(request.verification_code, time_zone_name: original_time_zone)
  end

  test "session failure rolls back owner attributes and verification and allows retry" do
    user = users(:bob)
    request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)
    original_time_zone = user.time_zone_name
    fail_session = ->(session) {
      session.errors.add(:base, "test failure")
      throw(:abort)
    }
    Session.set_callback(:create, :before, fail_session)
    begin
      assert_no_difference(-> { Session.count }) do
        assert_raises(ActiveRecord::RecordInvalid) do
          request.submit_code!(request.verification_code, time_zone_name: "Europe/London")
        end
      end
    ensure
      Session.skip_callback(:create, :before, fail_session)
    end
    assert_nil request.reload.verified_at
    assert_nil request.consumed_at
    assert_equal original_time_zone, user.reload.time_zone_name
    assert_kind_of Session, request.submit_code!(request.verification_code, time_zone_name: original_time_zone)
  end

  test "failed registration preserves permission and creates no partial account" do
    request = new_request
    token = request.submit_code!(request.verification_code)
    assert_no_difference [ -> { User.count }, -> { Session.count } ] do
      error = assert_raises(ActiveRecord::RecordInvalid) do
        request.complete_registration!(registration_attributes.merge(name: ""))
      end
      assert_kind_of User, error.record
    end
    assert PhoneNumberVerificationRequest.find_by_registration_token(token)
    assert_kind_of Session, request.reload.complete_registration!(registration_attributes)
  end

  test "session failure during registration rolls back the account and retains permission" do
    request = new_request
    token = request.submit_code!(request.verification_code)
    fail_session = ->(session) {
      session.errors.add(:base, "test failure")
      throw(:abort)
    }
    Session.set_callback(:create, :before, fail_session)
    begin
      assert_no_difference([ -> { User.count }, -> { Session.count } ]) do
        assert_raises(ActiveRecord::RecordInvalid) { request.complete_registration!(registration_attributes) }
      end
    ensure
      Session.skip_callback(:create, :before, fail_session)
    end
    assert_equal request, PhoneNumberVerificationRequest.find_by_registration_token(token)
    assert_kind_of Session, request.complete_registration!(registration_attributes)
  end

  test "registration collision never signs in the existing account" do
    request = new_request
    request.submit_code!(request.verification_code)
    User.create!(**registration_attributes, phone_number: request.phone_number)
    assert_no_difference [ -> { User.count }, -> { Session.count } ] do
      error = assert_raises(ActiveRecord::RecordInvalid) { request.complete_registration!(registration_attributes) }
      assert_predicate error.record.errors[:phone_number], :any?
    end
    assert_predicate request.reload, :registration_pending?
  end

  test "direct sessions require verified unused permission matching the user" do
    user = users(:bob)
    request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)
    assert_raises(ActiveRecord::RecordInvalid) { user.sessions.create!(phone_number_verification_request: request) }
    request.update!(verified_at: Time.current)
    assert_raises(ActiveRecord::RecordInvalid) do
      users(:sue).sessions.create!(phone_number_verification_request: request)
    end
    mismatched_user = users(:sue)
    mismatched_user.phone_number = request.phone_number
    assert_raises(ActiveRecord::RecordInvalid) do
      mismatched_user.sessions.create!(phone_number_verification_request: request)
    end
    session = user.sessions.create!(phone_number_verification_request: request)
    assert_predicate request.reload, :consumed_at?
    assert_raises(ActiveRecord::RecordInvalid) { user.sessions.create!(phone_number_verification_request: request) }
    assert session.update(updated_at: Time.current)
  end

  private

  def new_request
    PhoneNumberVerificationRequest.create!(phone_number: "+14165551234", user_agent: "test", ip_address: "127.0.0.1")
  end

  def registration_attributes
    { name: "new friend", unconfirmed_email_address: "friend@example.com", time_zone_name: "America/Toronto" }
  end
end
