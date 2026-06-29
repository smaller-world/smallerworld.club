# frozen_string_literal: true

class CreatePostTypeGrants < ActiveRecord::Migration[8.1]
  def change
    create_table :post_type_grants, id: :uuid do |t|
      t.belongs_to :world_key, null: false, foreign_key: true, type: :uuid
      t.belongs_to :post_type, null: false, foreign_key: true, type: :uuid
      t.index [ :world_key_id, :post_type_id ],
        unique: true,
        name: "index_post_type_grants_uniqueness"

      t.timestamptz :created_at, null: false
    end
  end
end
