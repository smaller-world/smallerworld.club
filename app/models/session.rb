# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: sessions
#
#  id                                   :uuid             not null, primary key
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  phone_number_verification_request_id :uuid             not null
#  user_id                              :uuid             not null
#
# Indexes
#
#  index_sessions_on_phone_number_verification_request_id  (phone_number_verification_request_id)
#  index_sessions_on_user_id                               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (phone_number_verification_request_id => phone_number_verification_requests.id)
#  fk_rails_...  (user_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Session < ApplicationRecord
  # == Associations ==

  belongs_to :user
  belongs_to :phone_number_verification_request

  sig { returns(User) }
  def user!
    user or raise "Missing user"
  end

  sig { returns(PhoneNumberVerificationRequest) }
  def phone_number_verification_request!
    phone_number_verification_request or
      raise "Missing associated phone number verification request"
  end

  # == Validations ==

  validate :validate_verified_phone_number_verification_request, on: :create

  # == Hooks ==

  around_create :consume_verification_request

  private

  # == Helpers ==

  sig { void }
  def validate_verified_phone_number_verification_request
    verification_request = phone_number_verification_request or return
    unless verification_request.verified? && !verification_request.consumed_at? &&
        User.exists?(id: user_id, phone_number: verification_request.phone_number)
      errors.add(:phone_number_verification_request, "must be verified, unused, and match the phone number")
    end
  end

  # Recheck after locking: validation alone races with another session creation.
  # The insert and durable consumption share the save transaction, even for
  # direct Session.create! callers. Existing session updates do not consume again.
  sig { params(block: T.proc.void).void }
  def consume_verification_request(&block)
    phone_number_verification_request!.with_lock(requires_new: true) do
      validate_verified_phone_number_verification_request
      raise ActiveRecord::RecordInvalid, self if errors.any?

      yield
      phone_number_verification_request!.update!(consumed_at: Time.current)
    end
  end
end
