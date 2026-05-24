class AddBlurbToWorlds < ActiveRecord::Migration[8.1]
  def change
    add_column :worlds, :blurb, :text
  end
end
