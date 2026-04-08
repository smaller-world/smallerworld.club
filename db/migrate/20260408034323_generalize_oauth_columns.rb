# typed: true
# frozen_string_literal: true

class GeneralizeOauthColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :apple_uid, :oauth_uid
    rename_column :users, :apple_first_name, :oauth_first_name
    rename_column :users, :apple_last_name, :oauth_last_name
    add_column :users, :oauth_provider, :string, null: false, default: "apple"
    change_column_default :users, :oauth_provider, from: "apple", to: nil

    remove_index :users, :oauth_uid
    add_index :users, [ :oauth_provider, :oauth_uid ], unique: true
  end
end
