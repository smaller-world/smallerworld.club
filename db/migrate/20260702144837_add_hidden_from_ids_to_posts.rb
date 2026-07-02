# frozen_string_literal: true

class AddHiddenFromIdsToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :hidden_from_ids, :uuid, array: true, null: false, default: []
    add_index :posts, :hidden_from_ids, using: :gin
  end
end
