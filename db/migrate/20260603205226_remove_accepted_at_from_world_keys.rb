# typed: true
# frozen_string_literal: true

class RemoveAcceptedAtFromWorldKeys < ActiveRecord::Migration[8.1]
  def change
    remove_column :world_keys, :accepted_at, :timestamptz
  end
end
