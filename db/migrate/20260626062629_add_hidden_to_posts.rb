# typed: true
# frozen_string_literal: true

class AddHiddenToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :hidden, :boolean
    up_only do
      execute <<~SQL.squish
        UPDATE posts
        SET hidden = post_types.default_hidden
        FROM post_types
        WHERE posts.type_id = post_types.id
          AND posts.hidden IS NULL ;
      SQL
    end
    change_column_null :posts, :hidden, false
  end
end
