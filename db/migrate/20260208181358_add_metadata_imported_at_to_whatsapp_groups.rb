# frozen_string_literal: true

class AddMetadataImportedAtToWhatsappGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :whatsapp_groups, :metadata_imported_at, :timestamptz
    add_index :whatsapp_groups, :metadata_imported_at
  end
end
