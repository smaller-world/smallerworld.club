# typed: true
# frozen_string_literal: true

class RenameMessagesIdToEventIdOnWebhookMessages < ActiveRecord::Migration[8.1]
  def change
    rename_column :webhook_messages, :messages_id, :event_id
    remove_index :webhook_messages, :event_id
    add_index :webhook_messages,
              [ :event, :event_id ],
              unique: true,
              name: "index_webhook_messages_uniqueness"
  end
end
