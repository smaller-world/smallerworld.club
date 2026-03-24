class RenameHandledAtToReplySentAtOnWhatsappMessages < ActiveRecord::Migration[8.1]
  def change
    rename_column :whatsapp_messages, :handled_at, :reply_sent_at
  end
end
