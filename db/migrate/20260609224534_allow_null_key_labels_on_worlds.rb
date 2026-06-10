# typed: true
# frozen_string_literal: true

class AllowNullKeyLabelsOnWorlds < ActiveRecord::Migration[8.1]
  def change
    change_column_null :worlds, :key_labels, true
    change_column_default :worlds, :key_labels, from: {}, to: nil
  end
end
