# frozen_string_literal: true

class CreateWorldCards < ActiveRecord::Migration[8.1]
  def change
    create_table :world_cards, id: :uuid do |t|
      t.belongs_to :world, null: false, foreign_key: true, type: :uuid
      t.belongs_to :cardholder, foreign_key: { to_table: "users" }, type: :uuid
      t.string :granted_key_color, null: false

      t.timestamps
    end
  end
end
