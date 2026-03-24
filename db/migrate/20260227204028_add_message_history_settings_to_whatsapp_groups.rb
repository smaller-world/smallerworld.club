class AddMessageHistorySettingsToWhatsappGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :whatsapp_groups, :message_history_enabled_at, :timestamptz
    execute "UPDATE whatsapp_groups SET message_history_enabled_at = created_at"
    change_column_null :whatsapp_groups, :message_history_enabled_at, false
    add_column :whatsapp_groups, :message_history_window_days, :integer
  end
end
