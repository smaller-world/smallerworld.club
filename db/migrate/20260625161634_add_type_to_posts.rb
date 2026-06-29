# typed: true
# frozen_string_literal: true

class AddTypeToPosts < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      DELETE FROM posts WHERE v1_attributes->>'type' = 'response'
    SQL
    add_reference :posts,
      :type,
      foreign_key: { to_table: "post_types" },
      type: :uuid
    when_clauses = V1::Post::V1_POST_TYPE_TO_TYPE_LABEL
      .map do |v1_type, label|
        "WHEN #{connection.quote(v1_type)} THEN #{connection.quote(label)}"
      end
      .join("\n")
    execute <<~SQL.squish
      UPDATE posts
      SET type_id = (
        SELECT id FROM post_types
        WHERE post_types.world_id = posts.world_id
        AND post_types.label = COALESCE(
          CASE posts.v1_attributes->>'type'
            #{when_clauses}
          END,
          'journal entry'
        )
      )
      WHERE type_id IS NULL;
    SQL
    change_column_null :posts, :type_id, false
    remove_reference :posts, :world
  end

  def down
    add_reference :posts,
      :world,
      foreign_key: true,
      type: :uuid
    execute <<~SQL.squish
      UPDATE posts
      SET world_id = (
        SELECT world_id FROM post_types
        WHERE post_types.id = posts.type_id
      )
      WHERE world_id IS NULL;
    SQL
    change_column_null :posts, :world_id, false
    remove_reference :posts, :type
  end
end
