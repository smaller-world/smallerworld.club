# typed: true
# frozen_string_literal: true

class EnforceWorldOnPostTypeGrants < ActiveRecord::Migration[8.1]
  def change
    add_column :post_type_grants, :world_id, :uuid
    up_only do
      execute <<~SQL.squish
        UPDATE post_type_grants
        SET world_id = world_keys.world_id
        FROM world_keys
        WHERE post_type_grants.world_key_id = world_keys.id
      SQL
    end
    change_column_null :post_type_grants, :world_id, false

    add_index :world_keys, [ :id, :world_id ], unique: true
    add_foreign_key :post_type_grants, :world_keys, column: [ :world_key_id, :world_id ], primary_key: [ :id, :world_id ]
    add_foreign_key :post_type_grants, :post_types, column: [ :post_type_id, :world_id ], primary_key: [ :id, :world_id ]
    remove_foreign_key :post_type_grants, :world_keys, column: :world_key_id
    remove_foreign_key :post_type_grants, :post_types, column: :post_type_id
  end
end
