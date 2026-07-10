# frozen_string_literal: true

class AddWorldLastVisitedAtToWorldKeys < ActiveRecord::Migration[8.1]
  def change
    add_column :world_keys, :world_last_visited_at, :timestamptz
  end
end
