# typed: true
# frozen_string_literal: true

class AddMutedPostTypeIdsToWorldKeys < ActiveRecord::Migration[8.1]
  def change
    add_column :world_keys,
      :muted_post_type_ids,
      :uuid,
      array: true,
      null: false,
      default: []
    add_index :world_keys, :muted_post_type_ids, using: :gin
  end
end
