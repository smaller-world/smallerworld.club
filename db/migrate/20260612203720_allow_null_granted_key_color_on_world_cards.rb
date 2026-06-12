# typed: true
# frozen_string_literal: true

class AllowNullGrantedKeyColorOnWorldCards < ActiveRecord::Migration[8.1]
  def change
    change_column_null :world_cards, :granted_key_color, true
  end
end
