# typed: true
# frozen_string_literal: true

class AddEventToWebhookMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :webhook_messages, :event, :string
    up_only do
      execute <<~SQL.squish
        UPDATE webhook_messages
        SET event = 'messages-group.received'
        WHERE event IS NULL
      SQL
    end
    change_column_null :webhook_messages, :event, false
  end
end
