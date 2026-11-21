# typed: true
# frozen_string_literal: true

class EnforceWorldOnKeyInvitations < ActiveRecord::Migration[8.1]
  def change
    add_index :world_invitations, [ :id, :world_id ], unique: true
    add_foreign_key :world_keys, :world_invitations, column: [ :invitation_id, :world_id ], primary_key: [ :id, :world_id ]
    remove_foreign_key :world_keys, :world_invitations, column: :invitation_id
  end
end
