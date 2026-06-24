# frozen_string_literal: true

# This migration comes from console1984 (originally 20210517203931)
class CreateConsole1984Tables < ActiveRecord::Migration[7.0]
  def change
    create_table :console1984_sessions, id: :uuid do |t|
      t.text :reason
      t.references :user, type: :uuid, null: false, index: false
      t.timestamps

      t.index :created_at
      t.index [ :user_id, :created_at ]
    end

    create_table :console1984_users, id: :uuid do |t|
      t.string :username, null: false
      t.timestamps

      t.index [ :username ]
    end

    create_table :console1984_commands, id: :uuid do |t|
      t.text :statements
      t.references :sensitive_access, type: :uuid
      t.references :session, type: :uuid, null: false, index: false
      t.timestamps

      t.index [ :session_id, :created_at, :sensitive_access_id ], name: "on_session_and_sensitive_chronologically"
    end

    create_table :console1984_sensitive_accesses, id: :uuid do |t|
      t.text :justification
      t.references :session, type: :uuid, null: false

      t.timestamps
    end
  end
end
