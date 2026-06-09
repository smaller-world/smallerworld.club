# typed: true
# frozen_string_literal: true

class AddRelevantDateToWorldCards < ActiveRecord::Migration[8.1]
  def change
    add_column :world_cards, :relevant_date, :timestamptz, default: -> { "NOW()" }
    add_index :world_cards, :relevant_date

    up_only do
      execute <<~SQL.squish
        UPDATE world_cards
        SET relevant_date = NOW()
        WHERE relevant_date IS NULL AND created_at < NOW() - INTERVAL '12 hours'
      SQL
    end
  end
end
