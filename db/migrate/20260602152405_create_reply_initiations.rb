# frozen_string_literal: true

class CreateReplyInitiations < ActiveRecord::Migration[8.1]
  def change
    create_table :reply_initiations, id: :uuid do |t|
      t.belongs_to :post, null: false, foreign_key: true, type: :uuid
      t.belongs_to :replier, null: false, foreign_key: { to_table: "users" }, type: :uuid
      t.string :platform, null: false

      t.timestamptz :created_at, null: false
    end
  end
end
