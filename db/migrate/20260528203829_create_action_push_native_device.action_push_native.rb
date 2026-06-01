# This migration comes from action_push_native (originally 20250610075650)
class CreateActionPushNativeDevice < ActiveRecord::Migration[8.0]
  def change
    create_table :devices, id: :uuid do |t|
      t.string :name
      t.string :platform, null: false
      t.string :token, null: false
      t.belongs_to :owner, type: :uuid, foreign_key: { to_table: "users" }, null: false
      t.string :installation_id, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
