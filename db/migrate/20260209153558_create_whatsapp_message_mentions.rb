# frozen_string_literal: true

class CreateWhatsappMessageMentions < ActiveRecord::Migration[8.1]
  def change
    create_table :whatsapp_message_mentions, id: :uuid do |t|
      t.belongs_to :message,
                   null: false,
                   foreign_key: { to_table: "whatsapp_messages" },
                   type: :uuid
      t.belongs_to :mentioned_user,
                   null: false,
                   foreign_key: { to_table: "whatsapp_users" },
                   type: :uuid

      t.timestamps
    end
  end
end
