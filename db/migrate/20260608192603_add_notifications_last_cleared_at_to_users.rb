# frozen_string_literal: true

class AddNotificationsLastClearedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :notifications_last_cleared_at, :timestamptz
  end
end
