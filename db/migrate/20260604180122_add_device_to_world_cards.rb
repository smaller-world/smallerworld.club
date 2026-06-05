# typed: true
# frozen_string_literal: true

class AddDeviceToWorldCards < ActiveRecord::Migration[8.1]
  def change
    remove_reference :world_cards, :cardholder, foreign_key: { to_table: "users" }, type: :uuid
    add_reference :world_cards, :device, foreign_key: true, type: :uuid
  end
end
