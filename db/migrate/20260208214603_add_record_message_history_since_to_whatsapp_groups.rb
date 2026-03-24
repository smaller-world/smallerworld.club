# typed: true
# frozen_string_literal: true

class AddRecordMessageHistorySinceToWhatsappGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :whatsapp_groups, :record_full_message_history_since, :timestamptz
  end
end
