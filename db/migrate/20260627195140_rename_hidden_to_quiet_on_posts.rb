# typed: true
# frozen_string_literal: true

class RenameHiddenToQuietOnPosts < ActiveRecord::Migration[8.1]
  def change
    rename_column :posts, :hidden, :quiet
    add_index :posts, :quiet
    change_column_default :posts, :quiet, from: nil, to: false
    remove_column :post_types, :default_hidden, :boolean, default: false
  end
end
