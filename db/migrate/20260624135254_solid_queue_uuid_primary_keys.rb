# typed: true
# frozen_string_literal: true

# Migrates all `solid_queue_*` tables from bigint primary/foreign keys to UUIDs.
#
# Performed in a single transaction (atomic schema flip) following the
# canonical 5-step zero-downtime shape:
#
#   1. Add UUID columns: `uuid` (PK, NOT NULL, default gen_random_uuid()) and
#      `<relation>_uuid` foreign keys (nullable, no default).
#   2. Backfill the new `<relation>_uuid` columns from the existing bigint FKs.
#   3. Enforce NOT NULL on the FKs that require it and promote `uuid` to the
#      primary key (after dropping the dependent FK constraints).
#   4. Drop the old bigint `id` / `<relation>_id` columns.
#   5. Rename `uuid` -> `id` and `<relation>_uuid` -> `<relation>_id`, then
#      restore the indexes and foreign-key constraints on the new columns.
class SolidQueueUuidPrimaryKeys < ActiveRecord::Migration[8.1]
  # Every solid_queue table gets a UUID primary key.
  PK_TABLES = [
    "solid_queue_blocked_executions",
    "solid_queue_claimed_executions",
    "solid_queue_failed_executions",
    "solid_queue_jobs",
    "solid_queue_pauses",
    "solid_queue_processes",
    "solid_queue_ready_executions",
    "solid_queue_recurring_executions",
    "solid_queue_recurring_tasks",
    "solid_queue_scheduled_executions",
    "solid_queue_semaphores",
  ].freeze

  # Foreign keys to convert. `constraint: true` means a DB-level FK constraint
  # (all of those reference solid_queue_jobs with ON DELETE CASCADE).
  FOREIGN_KEYS = {
    "solid_queue_blocked_executions" => [
      {
        from: "job_id",
        to: "job_uuid",
        references: "solid_queue_jobs",
        nullable: false,
        constraint: true,
      },
    ],
    "solid_queue_claimed_executions" => [
      {
        from: "job_id",
        to: "job_uuid",
        references: "solid_queue_jobs",
        nullable: false,
        constraint: true,
      },
      {
        from: "process_id",
        to: "process_uuid",
        references: "solid_queue_processes",
        nullable: true,
        constraint: false,
      },
    ],
    "solid_queue_failed_executions" => [
      {
        from: "job_id",
        to: "job_uuid",
        references: "solid_queue_jobs",
        nullable: false,
        constraint: true,
      },
    ],
    "solid_queue_ready_executions" => [
      {
        from: "job_id",
        to: "job_uuid",
        references: "solid_queue_jobs",
        nullable: false,
        constraint: true,
      },
    ],
    "solid_queue_recurring_executions" => [
      {
        from: "job_id",
        to: "job_uuid",
        references: "solid_queue_jobs",
        nullable: false,
        constraint: true,
      },
    ],
    "solid_queue_scheduled_executions" => [
      {
        from: "job_id",
        to: "job_uuid",
        references: "solid_queue_jobs",
        nullable: false,
        constraint: true,
      },
    ],
    "solid_queue_processes" => [
      {
        from: "supervisor_id",
        to: "supervisor_uuid",
        references: "solid_queue_processes",
        nullable: true,
        constraint: false,
      },
    ],
  }.freeze

  # Indexes that reference the converted columns. They are dropped together with
  # the old bigint columns and must be rebuilt against the new UUID columns.
  INDEXES = [
    [
      "solid_queue_blocked_executions",
      [ :concurrency_key, :priority, :job_id ],
      { name: "index_solid_queue_blocked_executions_for_release" },
    ],
    [
      "solid_queue_blocked_executions",
      :job_id,
      { unique: true, name: "index_solid_queue_blocked_executions_on_job_id" },
    ],
    [
      "solid_queue_claimed_executions",
      :job_id,
      { unique: true, name: "index_solid_queue_claimed_executions_on_job_id" },
    ],
    [
      "solid_queue_claimed_executions",
      [ :process_id, :job_id ],
      { name: "index_solid_queue_claimed_executions_on_process_id_and_job_id" },
    ],
    [
      "solid_queue_failed_executions",
      :job_id,
      { unique: true, name: "index_solid_queue_failed_executions_on_job_id" },
    ],
    [
      "solid_queue_processes",
      [ :name, :supervisor_id ],
      { unique: true, name: "index_solid_queue_processes_on_name_and_supervisor_id" },
    ],
    [
      "solid_queue_processes",
      :supervisor_id,
      { name: "index_solid_queue_processes_on_supervisor_id" },
    ],
    [
      "solid_queue_ready_executions",
      :job_id,
      { unique: true, name: "index_solid_queue_ready_executions_on_job_id" },
    ],
    [
      "solid_queue_ready_executions",
      [ :priority, :job_id ],
      { name: "index_solid_queue_poll_all" },
    ],
    [
      "solid_queue_ready_executions",
      [ :queue_name, :priority, :job_id ],
      { name: "index_solid_queue_poll_by_queue" },
    ],
    [
      "solid_queue_recurring_executions",
      :job_id,
      { unique: true, name: "index_solid_queue_recurring_executions_on_job_id" },
    ],
    [
      "solid_queue_scheduled_executions",
      :job_id,
      { unique: true, name: "index_solid_queue_scheduled_executions_on_job_id" },
    ],
    [
      "solid_queue_scheduled_executions",
      [ :scheduled_at, :priority, :job_id ],
      { name: "index_solid_queue_dispatch_all" },
    ],
  ].freeze

  def up
    # --- Step 1: add UUID primary-key and foreign-key columns ---------------
    PK_TABLES.each do |table|
      add_column table, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }
    end
    FOREIGN_KEYS.each do |table, fks|
      fks.each { |fk| add_column table, fk[:to], :uuid }
    end

    # --- Step 2: backfill the new foreign-key columns -----------------------
    FOREIGN_KEYS.each do |table, fks|
      fks.each do |fk|
        execute(<<~SQL.squish)
          UPDATE #{table} AS child
          SET #{fk[:to]} = parent.uuid
          FROM #{fk[:references]} AS parent
          WHERE child.#{fk[:from]} = parent.id
        SQL
      end
    end

    # --- Step 3: enforce NOT NULL and promote `uuid` to primary key ---------
    # Drop the FK constraints that depend on the bigint primary keys first.
    FOREIGN_KEYS.each do |table, fks|
      fks.each do |fk|
        next unless fk[:constraint]

        remove_foreign_key table, fk[:references], column: fk[:from]
      end
    end

    FOREIGN_KEYS.each do |table, fks|
      fks.each do |fk|
        change_column_null table, fk[:to], false unless fk[:nullable]
      end
    end

    PK_TABLES.each do |table|
      execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_pkey"
      execute "ALTER TABLE #{table} ADD PRIMARY KEY (uuid)"
    end

    # --- Step 4: drop the old bigint columns --------------------------------
    FOREIGN_KEYS.each do |table, fks|
      fks.each { |fk| remove_column table, fk[:from] }
    end
    PK_TABLES.each { |table| remove_column table, :id }

    # --- Step 5: rename UUID columns and restore indexes + constraints ------
    PK_TABLES.each { |table| rename_column table, :uuid, :id }
    FOREIGN_KEYS.each do |table, fks|
      fks.each { |fk| rename_column table, fk[:to], fk[:from] }
    end

    INDEXES.each { |table, columns, options| add_index table, columns, **options }

    FOREIGN_KEYS.each do |table, fks|
      fks.each do |fk|
        next unless fk[:constraint]

        add_foreign_key table, fk[:references], column: fk[:from], on_delete: :cascade
      end
    end
  end
end
