# typed: true
# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports, id: :uuid do |t|
      t.belongs_to :reportable, polymorphic: true, null: false, type: :uuid
      t.belongs_to :reporter, null: false, foreign_key: { to_table: "users" }, type: :uuid
      t.string :category, null: false
      t.text :note
      t.timestamptz :resolved_at, index: true

      t.timestamps
    end
  end
end
