# frozen_string_literal: true

class RenameLabelToNameOnPostTypes < ActiveRecord::Migration[8.1]
  def change
    rename_column :post_types, :label, :name
  end
end
