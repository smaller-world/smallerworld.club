# typed: true
# frozen_string_literal: true

class AddUniqueIndexOnUsersEmailAddress < ActiveRecord::Migration[8.1]
  def change
    add_index :users,
      "LOWER(email_address)",
      unique: true,
      where: "email_address IS NOT NULL",
      name: "index_users_on_email_addresses_case_insensitive"
  end
end
