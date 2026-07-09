# typed: true
# frozen_string_literal: true

class AddTypeIdCreatedAtIndexToPosts < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index :posts, :type_id
    add_index :posts, [ :type_id, :created_at ], algorithm: :concurrently
  end
end
