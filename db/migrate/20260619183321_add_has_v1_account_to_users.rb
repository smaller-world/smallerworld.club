# frozen_string_literal: true

class AddHasV1AccountToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :has_v1_account, :boolean, null: false, default: false
  end
end
