# typed: strict
# frozen_string_literal: true

require "test_helper"

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: registrations
#
#  id                                   :uuid             not null, primary key
#  completed_at                         :timestamptz
#  created_at                           :timestamptz      not null
#  created_user_id                      :uuid
#  phone_number_verification_request_id :uuid             not null
#
# Indexes
#
#  index_registrations_on_created_user_id                       (created_user_id) UNIQUE
#  index_registrations_on_phone_number_verification_request_id  (phone_number_verification_request_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_user_id => users.id)
#  fk_rails_...  (phone_number_verification_request_id => phone_number_verification_requests.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class RegistrationTest < ActiveSupport::TestCase
  test "registration requires a verified phone number" do
    verification_request = PhoneNumberVerificationRequest
      .create_test_mock_for!(users(:bob), verified: false)
    registration = Registration.new(phone_number_verification_request: verification_request)

    assert_not registration.valid?
    assert_includes registration.errors[:phone_number_verification_request], "must be verified"
  end

  test "a stale registration cannot complete again after the created user is deleted" do
    verification_request = PhoneNumberVerificationRequest.create!(
      phone_number: "+14165551234",
      ip_address: "127.0.0.1",
      user_agent: "test",
      verified_at: Time.current,
    )
    registration = Registration.create!(phone_number_verification_request: verification_request)
    stale_registration = Registration.find(registration.id)
    token = registration.generate_token_for(:completion)
    user = registration.complete!(
      name: "bobby", unconfirmed_email_address: "bobby@example.com", time_zone_name: "America/Toronto",
    )
    assert_equal verification_request.phone_number, user.phone_number
    assert_equal user, registration.created_user
    assert_nil Registration.find_by_token_for(:completion, token)

    user.destroy!

    assert_no_difference -> { User.count } do
      assert_raises Registration::AlreadyCompleted do
        stale_registration.complete!(
          name: "bobby", unconfirmed_email_address: "bobby@example.com", time_zone_name: "America/Toronto",
        )
      end
    end
    assert_nil registration.reload.created_user_id
    assert_predicate registration, :completed_at?
    assert_nil Registration.find_by_token_for(:completion, token)
  end
end
