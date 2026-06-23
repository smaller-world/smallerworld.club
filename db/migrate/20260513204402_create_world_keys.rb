# frozen_string_literal: true

class CreateWorldKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :world_keys, id: :uuid do |t|
      t.belongs_to :world, null: false, foreign_key: true, type: :uuid
      t.belongs_to :recipient, null: false, foreign_key: { to_table: "users" }, type: :uuid
      t.string :color, null: false
      t.index [ :world_id, :recipient_id, :color ], name: "index_world_keys_uniqueness", unique: true

      t.timestamps
    end
  end
end
