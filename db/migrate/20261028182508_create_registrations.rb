# typed: true
# frozen_string_literal: true

class CreateRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :registrations, id: :uuid do |t|
      t.references :phone_number_verification_request,
        type: :uuid,
        null: false,
        foreign_key: true,
        index: { unique: true }
      t.references :created_user,
        type: :uuid,
        null: true,
        foreign_key: { to_table: :users },
        index: { unique: true }
      t.timestamptz :completed_at
      t.timestamptz :created_at, null: false
    end
  end
end
