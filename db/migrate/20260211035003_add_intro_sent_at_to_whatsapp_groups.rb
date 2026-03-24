class AddIntroSentAtToWhatsappGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :whatsapp_groups, :intro_sent_at, :timestamptz
    add_index :whatsapp_groups, :intro_sent_at

    up_only do
      execute <<~SQL.squish
        UPDATE whatsapp_groups
        SET intro_sent_at = updated_at
        WHERE intro_sent_at IS NULL
      SQL
    end
  end
end
