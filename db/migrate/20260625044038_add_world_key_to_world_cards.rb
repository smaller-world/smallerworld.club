# typed: true
# frozen_string_literal: true

class AddWorldKeyToWorldCards < ActiveRecord::Migration[8.1]
  def change
    add_reference :world_cards,
      :world_key,
      foreign_key: true,
      type: :uuid

    execute <<~SQL.squish
      UPDATE world_cards
      SET world_key_id = (
        SELECT id FROM world_keys
        WHERE world_id = world_cards.world_id
        AND recipient_id = world_cards.cardholder_id
        ORDER BY created_at DESC
        LIMIT 1
      );
    SQL
  end
end
