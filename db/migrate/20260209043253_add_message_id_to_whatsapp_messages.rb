# frozen_string_literal: true

class AddMessageIdToWhatsappMessages < ActiveRecord::Migration[8.1]
  def change
    execute "DELETE FROM whatsapp_messages"
    add_column :whatsapp_messages, :message_id, :string, null: false
  end
end
