# typed: true
# frozen_string_literal: true

class AddAcceptedAtToWorldKeys < ActiveRecord::Migration[8.1]
  def change
    add_column :world_keys, :accepted_at, :timestamptz
    add_index :world_keys, :accepted_at
    execute <<~SQL.squish
      UPDATE world_keys
      SET accepted_at = created_at
      WHERE accepted_at IS NULL;
    SQL
  end
end
