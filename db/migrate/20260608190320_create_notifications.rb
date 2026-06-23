# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications, id: :uuid do |t|
      t.timestamptz :delivered_at
      t.timestamptz :received_at
      t.belongs_to :recipient, null: false, foreign_key: { to_table: "users" }, type: :uuid
      t.belongs_to :noticeable, polymorphic: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
