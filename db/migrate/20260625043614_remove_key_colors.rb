# typed: true
# frozen_string_literal: true

class RemoveKeyColors < ActiveRecord::Migration[8.1]
  def up
    remove_column :world_keys, :color
    execute <<~SQL.squish
      DELETE FROM world_keys
      WHERE ctid NOT IN (
        SELECT min(ctid)
        FROM world_keys
        GROUP BY world_id, recipient_id
      );
    SQL
    add_index :world_keys,
      [ :world_id, :recipient_id ],
      unique: true,
      name: "index_world_keys_uniqueness"
    remove_column :world_cards, :granted_key_color
    remove_column :posts, :key_colors
  end
end
