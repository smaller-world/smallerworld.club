# typed: true
# frozen_string_literal: true

# This migration comes from action_push_native (originally 20250610075650)
class CreateActionPushNativeDevice < ActiveRecord::Migration[8.0]
  def change
    create_table :action_push_native_devices, id: :uuid do |t|
      t.string :name
      t.string :installation_id, null: false
      t.string :platform, null: false
      t.string :token, null: false
      t.belongs_to :owner,
                   type: :uuid,
                   null: false,
                   foreign_key: { to_table: 'users' }

      t.timestamps

      t.index %i[installation_id owner_id],
              unique: true,
              name: "index_action_push_native_devices_uniqueness"
    end
  end
end
