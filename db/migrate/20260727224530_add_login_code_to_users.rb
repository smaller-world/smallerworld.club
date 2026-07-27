# typed: true
# frozen_string_literal: true

class AddLoginCodeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :login_code, :string
  end
end
