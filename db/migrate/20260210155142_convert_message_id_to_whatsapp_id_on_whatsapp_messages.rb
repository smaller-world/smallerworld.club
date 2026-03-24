# typed: true

class ConvertMessageIdToWhatsappIdOnWhatsappMessages < ActiveRecord::Migration[8.1]
  def change
    rename_column :whatsapp_messages, :message_id, :whatsapp_id
    # change_column :whatsapp_messages,
    #               :whatsapp_id,
    #               :bigint,
    #               using: "whatsapp_id::bigint"
  end

  # def down
  #   change_column :whatsapp_messages, :whatsapp_id, :string
  #   rename_column :whatsapp_messages, :whatsapp_id, :message_id
  # end
end
