# typed: true
# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events, id: :uuid do |t|
      t.string :luma_id, null: false, index: { unique: true }
      t.tstzrange :duration, null: false
      t.jsonb :geo_address
      t.st_point :geo_location, geographic: true
      t.string :name, null: false
      t.text :description, null: false
      t.text :description_md, null: false
      t.string :time_zone_name, null: false
      t.string :tag_ids, null: false, default: [], array: true
      t.string :luma_url, null: false

      t.timestamps
    end
  end
end
