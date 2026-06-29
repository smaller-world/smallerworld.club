# typed: true
# frozen_string_literal: true

class CreateWorldInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :world_invitations, id: :uuid do |t|
      t.belongs_to :world, null: false, foreign_key: true, type: :uuid
      t.uuid :granted_post_type_ids, array: true, null: false
      t.string :recipient_phone_number, null: false
      t.belongs_to :recipient, foreign_key: { to_table: "users" }, type: :uuid
      t.index [ :world_id, :recipient_phone_number ],
        unique: true,
        name: "index_world_invitations_uniqueness"

      t.timestamps
    end

    change_table :world_keys do |t|
      t.remove :accepted_at, type: :timestamptz
      t.belongs_to :invitation,
        foreign_key: { to_table: "world_invitations" },
        type: :uuid
    end
  end
end
