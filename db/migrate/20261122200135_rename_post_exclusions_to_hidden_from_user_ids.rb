# frozen_string_literal: true

class RenamePostExclusionsToHiddenFromUserIds < ActiveRecord::Migration[8.1]
  def change
    rename_column :posts, :hidden_from_ids, :hidden_from_user_ids
  end
end
