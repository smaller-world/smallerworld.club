# typed: true
# frozen_string_literal: true

class EnforcePostTypeWorldOnPosts < ActiveRecord::Migration[8.1]
  def change
    add_index :post_types, [ :id, :world_id ], unique: true
    add_foreign_key :posts, :post_types, column: [ :type_id, :world_id ], primary_key: [ :id, :world_id ]
    remove_foreign_key :posts, :post_types, column: :type_id
  end
end
