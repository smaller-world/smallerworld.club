class AddMetadataImportedAtToWhatsappUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :whatsapp_users, :metadata_imported_at, :timestamptz
    add_index :whatsapp_users, :metadata_imported_at
  end
end
