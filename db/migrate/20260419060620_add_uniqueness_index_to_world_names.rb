# typed: true
# frozen_string_literal: true

class AddUniquenessIndexToWorldNames < ActiveRecord::Migration[8.1]
  def change
    add_index :worlds,
      [ :name, :owner_id ],
      name: "index_worlds_on_name_and_owner_id",
      unique: true
  end
end
