# typed: true
# frozen_string_literal: true

class RevertWorldKeyColorRenameOnPosts < ActiveRecord::Migration[8.1]
  def change
    rename_column :posts, :world_key_colors, :key_colors
  end
end
