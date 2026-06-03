# typed: true
# frozen_string_literal: true

class RemoveDataFromPasskitPasses < ActiveRecord::Migration[8.1]
  def change
    remove_column :passkit_passes, :data, :json
  end
end
