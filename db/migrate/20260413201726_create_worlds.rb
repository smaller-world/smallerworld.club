# typed: true
# frozen_string_literal: true

class CreateWorlds < ActiveRecord::Migration[8.1]
  def change
    create_table :worlds, id: :uuid do |t|
      t.string :name, null: false
      t.belongs_to :owner,
        null: false,
        foreign_key: { to_table: "users" },
        type: :uuid

      t.timestamps
    end
  end
end
