class AddFullNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :apple_first_name, :string, null: false
    add_column :users, :apple_last_name, :string, null: false
  end
end
