# frozen_string_literal: true

class CreateWebhookMessages < ActiveRecord::Migration[8.1]
  def change
    create_table(:webhook_messages, id: :uuid) do |t|
      t.timestamptz :timestamp, null: false, index: true
      t.timestamptz :created_at, null: false
      t.string :messages_id, null: false, index: { unique: true }
      t.jsonb :data, null: false
    end
  end
end
