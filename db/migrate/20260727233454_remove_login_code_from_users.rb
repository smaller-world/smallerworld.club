# typed: true
# frozen_string_literal: true

class RemoveLoginCodeFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :login_code, :string
  end
end
