# frozen_string_literal: true

class AddAcceptedAtToWorldKeys2 < ActiveRecord::Migration[8.1]
  def change
    add_column :world_keys, :accepted_at, :timestamptz
    add_index :world_keys, :accepted_at
  end
end
