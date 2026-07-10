# typed: true
# frozen_string_literal: true

class RenameAppLastVisitedAtOnUsers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :notifications_last_cleared_at, :app_last_visited_at
  end
end
