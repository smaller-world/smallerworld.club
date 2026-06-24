# typed: true
# frozen_string_literal: true

# Migrates the `solid_cache_entries` table from a bigint primary key to a UUID.
#
# Solid Cache has a single table with no foreign keys and no indexes on `id`
# (its indexes cover `byte_size` and `key_hash`), so the canonical 5-step shape
# collapses to: add `uuid`, promote it to the primary key, drop the old bigint
# `id`, then rename `uuid` -> `id`. Performed in a single transaction for an
# atomic schema flip.
class SolidCacheUuidPrimaryKeys < ActiveRecord::Migration[8.1]
  TABLE = "solid_cache_entries"

  def up
    # Step 1: add the UUID primary-key column.
    add_column TABLE, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }

    # Step 3: promote `uuid` to the primary key.
    execute "ALTER TABLE #{TABLE} DROP CONSTRAINT #{TABLE}_pkey"
    execute "ALTER TABLE #{TABLE} ADD PRIMARY KEY (uuid)"

    # Step 4: drop the old bigint column.
    remove_column TABLE, :id

    # Step 5: rename the UUID column into place.
    rename_column TABLE, :uuid, :id
  end
end
