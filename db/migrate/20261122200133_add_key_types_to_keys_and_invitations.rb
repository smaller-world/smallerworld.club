# frozen_string_literal: true

class AddKeyTypesToKeysAndInvitations < ActiveRecord::Migration[8.1]
  def change
    add_column :world_keys, :type_id, :uuid
    add_foreign_key :world_keys,
      :world_key_types,
      column: [ :world_id, :type_id ],
      primary_key: [ :world_id, :id ]

    add_column :world_invitations, :key_type_id, :uuid
    add_foreign_key :world_invitations,
      :world_key_types,
      column: [ :world_id, :key_type_id ],
      primary_key: [ :world_id, :id ]
  end
end
