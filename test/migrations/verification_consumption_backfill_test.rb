# typed: true
# frozen_string_literal: true

require "test_helper"
require_relative "../../db/migrate/20261027160000_add_consumed_at_to_phone_number_verification_requests"

class VerificationConsumptionBackfillTest < ActiveSupport::TestCase
  test "backfill preserves recent registration tokens and sessions and consumes other verified requests" do
    recent = make_request(created_at: 30.minutes.ago, verified_at: 29.minutes.ago)
    old = make_request(created_at: 2.hours.ago, verified_at: 119.minutes.ago)
    matching = make_request(
      created_at: 30.minutes.ago,
      verified_at: 29.minutes.ago,
      phone_number: users(:bob).phone_number,
    )
    pending = make_request(created_at: 2.hours.ago)
    session = users(:bob).sessions.create!(phone_number_verification_request: matching)
    token = recent.generate_registration_token
    old_token = old.generate_registration_token
    original_sessions = Session.count

    # Exercise the actual migration against its pre-migration schema, in a
    # transaction so this test restores the column for the rest of the suite.
    migration = AddConsumedAtToPhoneNumberVerificationRequests.new
    migration.migrate(:down)
    migration.migrate(:up)

    assert_nil recent.reload.consumed_at
    assert_equal recent, PhoneNumberVerificationRequest.find_by_registration_token(token)
    assert_predicate old.reload, :consumed_at?
    assert_nil PhoneNumberVerificationRequest.find_by_registration_token(old_token)
    assert_predicate matching.reload, :consumed_at?
    assert_nil pending.reload.consumed_at
    assert_nil pending.verified_at
    assert_equal original_sessions, Session.count
    assert_equal users(:bob), session.reload.user
    assert session.update(updated_at: Time.current)
  end

  private

  def make_request(**attributes)
    PhoneNumberVerificationRequest.create!(
      phone_number: "+14165551234", user_agent: "test", ip_address: "127.0.0.1", **attributes,
    )
  end
end
