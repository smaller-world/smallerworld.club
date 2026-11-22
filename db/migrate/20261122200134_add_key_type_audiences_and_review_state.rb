# frozen_string_literal: true

class AddKeyTypeAudiencesAndReviewState < ActiveRecord::Migration[8.1]
  def change
    change_table :posts do |t|
      t.uuid :visible_to_key_type_ids, array: true, default: [], null: false
      t.uuid :visible_to_user_ids, array: true, default: [], null: false
    end

    add_column :worlds, :key_types_review_pending, :boolean, default: false, null: false

    up_only do
      execute "UPDATE worlds SET key_types_review_pending = TRUE"
    end
  end
end
