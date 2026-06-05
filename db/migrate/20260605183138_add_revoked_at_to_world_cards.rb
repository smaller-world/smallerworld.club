# typed: true
# frozen_string_literal: true

class AddRevokedAtToWorldCards < ActiveRecord::Migration[8.1]
  def change
    add_column :world_cards, :revoked_at, :timestamptz
    add_index :world_cards, :revoked_at
  end
end
