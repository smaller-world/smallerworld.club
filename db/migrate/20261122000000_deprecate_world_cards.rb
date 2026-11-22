# typed: true
# frozen_string_literal: true

class DeprecateWorldCards < ActiveRecord::Migration[8.1]
  def change
    rename_table :world_cards, :deprecated_world_cards
  end
end
