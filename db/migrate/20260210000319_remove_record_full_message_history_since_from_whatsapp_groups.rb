# frozen_string_literal: true

class RemoveRecordFullMessageHistorySinceFromWhatsappGroups < ActiveRecord::Migration[8.1]
  def change
    remove_column :whatsapp_groups, :record_full_message_history_since, :timestamptz
  end
end
