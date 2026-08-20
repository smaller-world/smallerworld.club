# typed: true
# frozen_string_literal: true

class AddWorldToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :world, null: true, foreign_key: true, type: :uuid
    up_only do
      execute <<~SQL.squish
        UPDATE posts
        SET world_id = post_types.world_id
        FROM post_types
        WHERE posts.type_id = post_types.id
      SQL
    end
    change_column_null :posts, :world_id, false
  end
end
