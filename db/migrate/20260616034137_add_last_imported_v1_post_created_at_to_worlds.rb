# typed: true
# frozen_string_literal: true

class AddLastImportedV1PostCreatedAtToWorlds < ActiveRecord::Migration[8.1]
  def change
    add_column :worlds, :last_imported_v1_post_created_at, :timestamptz
  end
end
