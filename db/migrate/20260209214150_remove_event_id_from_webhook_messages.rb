# frozen_string_literal: true

class RemoveEventIdFromWebhookMessages < ActiveRecord::Migration[8.1]
  def change
    remove_column :webhook_messages, :event_id, :string
  end
end
