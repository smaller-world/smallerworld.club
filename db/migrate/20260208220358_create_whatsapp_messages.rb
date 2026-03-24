# typed: true
# frozen_string_literal: true

class CreateWhatsappMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :whatsapp_messages, id: :uuid do |t|
      t.belongs_to :sender,
                   null: false,
                   foreign_key: { to_table: "whatsapp_users" },
                   type: :uuid
      t.belongs_to :group,
                   null: false,
                   foreign_key: { to_table: "whatsapp_groups" },
                   type: :uuid
      t.text :body
      t.timestamptz :timestamp, null: false, index: true

      t.timestamps
    end
  end
end
