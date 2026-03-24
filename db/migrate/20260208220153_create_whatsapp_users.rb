# typed: true
# frozen_string_literal: true

class CreateWhatsappUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :whatsapp_users, id: :uuid do |t|
      t.string :display_name
      t.string :jid, null: false

      t.timestamps
    end
  end
end
