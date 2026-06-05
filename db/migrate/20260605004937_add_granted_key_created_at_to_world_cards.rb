class AddGrantedKeyCreatedAtToWorldCards < ActiveRecord::Migration[8.1]
  def change
    add_column :world_cards, :granted_key_created_at, :timestamptz
  end
end
