class CreateReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :reactions, id: :uuid do |t|
      t.belongs_to :post, null: false, foreign_key: true, type: :uuid
      t.string :emoji, null: false
      t.belongs_to :reactor, null: false, foreign_key: { to_table: "users" }, type: :uuid
      t.timestamptz :created_at, null: false
      t.index [ :post_id, :emoji, :reactor_id ],
        unique: true,
        name: "index_reactions_uniqueness"
    end
  end
end
