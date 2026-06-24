# typed: true
# frozen_string_literal: true

# Reverts `solid_cable_messages` from a UUID primary key back to a bigint.
#
# Solid Cable's pub/sub is a polling cursor over `id`: the adapter tracks the
# last-seen `id` as an integer and fetches new rows with `where(id: last_id + 1..)`
# ordered by `id` (see SolidCable::Message.broadcastable and the SolidCable
# subscription adapter). That mechanism REQUIRES a monotonically increasing
# integer key -- random UUIDs make `last_id.to_i` collapse to 0, break the
# ordering, and compare incompatible types, so no broadcast is ever delivered.
#
# Messages are transient (1-day retention), so existing rows are kept but
# reseeded with fresh sequential ids via `bigserial`.
class RevertSolidCableUuidPrimaryKeys < ActiveRecord::Migration[8.1]
  TABLE = "solid_cable_messages"

  def up
    # Add a fresh bigint identity column (creates a sequence, assigns sequential
    # values to existing rows in physical/insertion order).
    execute "ALTER TABLE #{TABLE} ADD COLUMN new_id bigserial NOT NULL"

    # Promote it to the primary key.
    execute "ALTER TABLE #{TABLE} DROP CONSTRAINT #{TABLE}_pkey"
    execute "ALTER TABLE #{TABLE} ADD PRIMARY KEY (new_id)"

    # Drop the UUID column and rename the bigint into place.
    remove_column TABLE, :id
    rename_column TABLE, :new_id, :id

    # Give the sequence its conventional name.
    execute "ALTER SEQUENCE #{TABLE}_new_id_seq RENAME TO #{TABLE}_id_seq"
  end

  def down
    add_column TABLE, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }
    execute "ALTER TABLE #{TABLE} DROP CONSTRAINT #{TABLE}_pkey"
    execute "ALTER TABLE #{TABLE} ADD PRIMARY KEY (uuid)"
    remove_column TABLE, :id
    rename_column TABLE, :uuid, :id
  end
end
