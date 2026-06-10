# typed: true
# frozen_string_literal: true

class RenameKeyColorsToWorldKeyColorsOnPosts < ActiveRecord::Migration[8.1]
  def change
    rename_column :posts, :key_colors, :world_key_colors
  end
end
