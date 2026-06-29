# typed: true
# frozen_string_literal: true

class SetEmptyDefaultGrantedPostTypeIdsOnWorldInvitations < ActiveRecord::Migration[8.1]
  def change
    change_column_default :world_invitations, :granted_post_type_ids, from: nil, to: []
  end
end
