# frozen_string_literal: true

class RenameLegacyInvitationGrantedPostTypes < ActiveRecord::Migration[8.1]
  def change
    rename_column :world_invitations, :granted_post_type_ids, :deprecated_granted_post_type_ids
  end
end
