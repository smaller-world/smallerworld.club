# frozen_string_literal: true

class AddKeyLabelsToWorlds < ActiveRecord::Migration[8.1]
  def change
    add_column :worlds, :key_labels, :jsonb, null: false, default: {}
  end
end
