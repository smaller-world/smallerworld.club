# typed: true
# frozen_string_literal: true

class AddCardholderToWorldCards < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :world_cards,
      :cardholder,
      foreign_key: { to_table: "users" },
      type: :uuid,
    )
    up_only do
      execute <<~SQL.squish
        UPDATE world_cards AS world_card
        SET cardholder_id = devices.owner_id
        FROM devices
        WHERE world_card.device_id = devices.id
          AND devices.owner_id IS NOT NULL
      SQL
    end
  end
end
