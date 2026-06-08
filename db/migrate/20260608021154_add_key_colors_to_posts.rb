class AddKeyColorsToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :key_colors, :string, array: true
    add_index :posts, :key_colors
  end
end
