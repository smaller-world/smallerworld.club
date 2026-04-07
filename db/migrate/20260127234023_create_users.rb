# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table(:users, id: :uuid) do |t|
      t.string :email_address, null: false, index: { unique: true }
      t.string :phone_number, index: true
      t.string :name, null: false
      t.string :time_zone_name, null: false
      t.string :apple_uid, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
