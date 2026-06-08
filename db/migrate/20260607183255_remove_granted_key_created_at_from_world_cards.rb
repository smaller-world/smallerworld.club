# typed: true
# frozen_string_literal: true

class RemoveGrantedKeyCreatedAtFromWorldCards < ActiveRecord::Migration[8.1]
  def change
    remove_column :world_cards, :granted_key_created_at, :string
  end
end
