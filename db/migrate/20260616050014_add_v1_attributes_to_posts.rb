class AddV1AttributesToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :v1_attributes, :jsonb
  end
end
