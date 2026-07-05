# typed: true
# frozen_string_literal: true

class IndexDevicesOnPushTokens < ActiveRecord::Migration[8.1]
  def change
    up_only do
      execute(<<~SQL.squish)
        DELETE FROM devices
        WHERE id IN (
          SELECT id FROM (
            SELECT id, ROW_NUMBER() OVER (
              PARTITION BY push_token ORDER BY created_at DESC
            ) AS row_number
            FROM devices
            WHERE push_token IS NOT NULL
          ) duplicates
          WHERE duplicates.row_number > 1
        )
      SQL
    end
    add_index :devices, :push_token, unique: true
  end
end
