# typed: true
# frozen_string_literal: true

class RemoveKeyLabelsFromWorlds < ActiveRecord::Migration[8.1]
  def up
    remove_column :worlds, :key_labels
  end
end
