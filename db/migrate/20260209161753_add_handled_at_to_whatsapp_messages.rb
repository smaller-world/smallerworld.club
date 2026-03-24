# frozen_string_literal: true

class AddHandledAtToWhatsappMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :whatsapp_messages, :handled_at, :timestamptz
    add_index :whatsapp_messages, :handled_at
    change_column_null :whatsapp_messages, :body, false
  end
end
