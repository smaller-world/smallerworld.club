# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts, id: :uuid do |t|
      t.belongs_to :world, null: false, foreign_key: true, type: :uuid
      t.string :title
      t.text :plain_body, null: false

      t.timestamps
    end
  end
end
