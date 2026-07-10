# typed: true
# frozen_string_literal: true

class RevertSolidCacheEntriesToBigintPrimaryKey < ActiveRecord::Migration[8.1]
  def up
    # solid_cache_entries is a disposable cache table, so it's safe to drop and
    # recreate it with a bigint primary key (solid_cache is incompatible with
    # uuid primary keys).
    drop_table :solid_cache_entries

    create_table :solid_cache_entries do |t|
      t.binary :key, null: false
      t.binary :value, null: false
      t.datetime :created_at, null: false
      t.integer :byte_size, null: false
      t.bigint :key_hash, null: false

      t.index :byte_size, name: "index_solid_cache_entries_on_byte_size"
      t.index [ :key_hash, :byte_size ], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
      t.index :key_hash, unique: true, name: "index_solid_cache_entries_on_key_hash"
    end
  end

  def down
    drop_table :solid_cache_entries

    create_table :solid_cache_entries, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.binary :key, null: false
      t.binary :value, null: false
      t.datetime :created_at, null: false
      t.integer :byte_size, null: false
      t.bigint :key_hash, null: false

      t.index :byte_size, name: "index_solid_cache_entries_on_byte_size"
      t.index [ :key_hash, :byte_size ], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
      t.index :key_hash, unique: true, name: "index_solid_cache_entries_on_key_hash"
    end
  end
end
