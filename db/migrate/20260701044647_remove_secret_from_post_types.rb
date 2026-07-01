# typed: true
# frozen_string_literal: true

class RemoveSecretFromPostTypes < ActiveRecord::Migration[8.1]
  def change
    up_only do
      execute <<~SQL.squish
        INSERT INTO post_type_grants (post_type_id, world_key_id, created_at)
        SELECT post_types.id, world_keys.id, now()
        FROM post_types
        JOIN world_keys ON world_keys.world_id = post_types.world_id
        WHERE post_types.secret = false
        ON CONFLICT (world_key_id, post_type_id) DO NOTHING
      SQL
    end
    remove_column :post_types, :secret, :string, null: false, default: false
  end
end
