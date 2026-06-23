# frozen_string_literal: true

class AddEmojiToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :emoji, :string
  end
end
