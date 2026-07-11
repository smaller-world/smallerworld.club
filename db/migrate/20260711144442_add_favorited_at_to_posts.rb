# typed: true
# frozen_string_literal: true

class AddFavoritedAtToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :favorited_at, :timestamptz
    add_index :posts, :favorited_at
  end
end
