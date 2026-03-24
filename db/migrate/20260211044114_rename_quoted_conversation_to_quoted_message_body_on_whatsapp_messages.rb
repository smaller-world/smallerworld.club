class RenameQuotedConversationToQuotedMessageBodyOnWhatsappMessages < ActiveRecord::Migration[8.1]
  def change
    rename_column :whatsapp_messages,
                  :quoted_conversation,
                  :quoted_message_body
  end
end
