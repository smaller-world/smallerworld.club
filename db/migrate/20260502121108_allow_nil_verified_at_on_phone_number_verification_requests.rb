# typed: true
# frozen_string_literal: true

class AllowNilVerifiedAtOnPhoneNumberVerificationRequests < ActiveRecord::Migration[8.1]
  def change
    change_column_null :phone_number_verification_requests, :verified_at, true
  end
end
