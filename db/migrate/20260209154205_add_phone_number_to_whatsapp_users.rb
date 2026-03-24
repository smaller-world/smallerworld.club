# typed: true
# frozen_string_literal: true

class AddPhoneNumberToWhatsappUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :whatsapp_users, :phone_number, :string
    add_index :whatsapp_users, :phone_number, unique: true
    add_column :whatsapp_users, :lid, :string, null: false
    add_index :whatsapp_users, :lid, unique: true
    change_column_null :whatsapp_users, :jid, true
    rename_column :whatsapp_users, :jid, :phone_number_jid
  end
end
