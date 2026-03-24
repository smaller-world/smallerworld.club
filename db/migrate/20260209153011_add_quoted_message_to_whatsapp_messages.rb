# typed: true
# frozen_string_literal: true

class AddQuotedMessageToWhatsappMessages < ActiveRecord::Migration[8.1]
  def change
    add_reference :whatsapp_messages,
                  :quoted_message,
                  foreign_key: { to_table: "whatsapp_messages" },
                  type: :uuid
    add_column :whatsapp_messages, :quoted_conversation, :text
    add_column :whatsapp_messages, :quoted_participant_jid, :string
  end
end
