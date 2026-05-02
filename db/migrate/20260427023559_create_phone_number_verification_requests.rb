# typed: true
# frozen_string_literal: true

class CreatePhoneNumberVerificationRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :phone_number_verification_requests, id: :uuid do |t|
      t.string :phone_number, null: false
      t.string :verification_code, null: false
      t.inet :ip_address, null: false

      t.timestamptz :created_at, null: false
      t.timestamptz :verified_at
    end
  end
end
