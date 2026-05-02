# typed: true
# frozen_string_literal: true

class AddUniquePhoneNumberIndexToUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :email_address
    remove_index :users, :phone_number
    add_index :users, :phone_number, unique: true
  end
end
