# typed: true
# frozen_string_literal: true

class CreatePostTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :post_types, id: :uuid do |t|
      t.belongs_to :world, null: false, foreign_key: true, type: :uuid
      t.string :label, null: false
      t.string :icon
      t.boolean :secret, null: false, default: false
      t.boolean :default_hidden, null: false, default: false
      t.index [ :world_id, :label ], unique: true, name: "index_post_types_uniqueness"

      t.timestamps
    end
  end
end
