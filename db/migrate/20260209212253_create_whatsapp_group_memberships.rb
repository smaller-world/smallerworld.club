# typed: true
# frozen_string_literal: true

class CreateWhatsappGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :whatsapp_group_memberships, id: :uuid do |t|
      t.belongs_to :group,
                   null: false,
                   foreign_key: { to_table: "whatsapp_groups" },
                   type: :uuid
      t.belongs_to :user,
                   null: false,
                   foreign_key: { to_table: "whatsapp_users" },
                   type: :uuid
      t.string :admin

      t.timestamps
    end

    change_table :whatsapp_groups do |t|
      t.timestamptz :memberships_imported_at, index: true
    end
  end
end
