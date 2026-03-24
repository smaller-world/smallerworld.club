class AddUniquenessIndexToWhatsappGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    add_index :whatsapp_group_memberships,
              [ :group_id, :user_id ],
              unique: true,
              name: "index_whatsapp_group_memberships_uniqueness"
  end
end
