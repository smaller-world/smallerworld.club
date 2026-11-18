# frozen_string_literal: true

class CreateReflections < ActiveRecord::Migration[8.1]
  def change
    create_table :reflections, id: :uuid do |t|
      t.date :date, null: false
      t.belongs_to :author, null: false, foreign_key: { to_table: "users" }, type: :uuid
      t.string :emoji
      t.index [ :date, :author_id ], unique: true, name: "index_reflections_uniqueness"

      t.timestamps
    end
  end
end
