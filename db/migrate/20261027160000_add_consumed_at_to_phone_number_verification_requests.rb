# typed: true
# frozen_string_literal: true

class AddConsumedAtToPhoneNumberVerificationRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :phone_number_verification_requests, :consumed_at, :timestamptz

    up_only do
      # One cutoff for the entire backfill; do not bind this to application models.
      cutoff = connection.quote(1.hour.ago)
      execute <<~SQL.squish
        UPDATE phone_number_verification_requests AS requests
        SET consumed_at = verified_at
        WHERE verified_at IS NOT NULL
          AND (created_at < #{cutoff} OR EXISTS (
            SELECT 1 FROM users WHERE users.phone_number = requests.phone_number
          ))
      SQL
    end
  end
end
