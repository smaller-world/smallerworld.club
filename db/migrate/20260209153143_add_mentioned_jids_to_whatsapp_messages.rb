# frozen_string_literal: true

class AddMentionedJidsToWhatsappMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :whatsapp_messages,
               :mentioned_jids,
               :string,
               array: true,
               null: false,
               default: []
  end
end
