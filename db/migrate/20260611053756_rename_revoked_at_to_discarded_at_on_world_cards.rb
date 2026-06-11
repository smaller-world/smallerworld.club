# typed: true
# frozen_string_literal: true

class RenameRevokedAtToDiscardedAtOnWorldCards < ActiveRecord::Migration[8.1]
  def change
    rename_column :world_cards, :revoked_at, :discarded_at
  end
end
