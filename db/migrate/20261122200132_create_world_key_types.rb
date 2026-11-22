# frozen_string_literal: true

class CreateWorldKeyTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :world_key_types, id: :uuid do |t|
      t.references :world, null: false, foreign_key: true, type: :uuid, index: false
      t.string :name, null: false
      t.string :color, null: false

      t.timestamps

      t.index [ :world_id, :name ], unique: true
      t.index [ :world_id, :id ], unique: true
    end
  end
end
