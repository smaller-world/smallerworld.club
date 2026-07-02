# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_02_144837) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_record_internal_metadata", primary_key: "key", id: :string, force: :cascade do |t|
    t.timestamptz "created_at", precision: 6, null: false
    t.timestamptz "updated_at", precision: 6, null: false
    t.string "value"
  end

  create_table "active_record_schema_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "console1984_commands", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "sensitive_access_id"
    t.uuid "session_id", null: false
    t.text "statements"
    t.datetime "updated_at", null: false
    t.index ["sensitive_access_id"], name: "index_console1984_commands_on_sensitive_access_id"
    t.index ["session_id", "created_at", "sensitive_access_id"], name: "on_session_and_sensitive_chronologically"
  end

  create_table "console1984_sensitive_accesses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "justification"
    t.uuid "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_console1984_sensitive_accesses_on_session_id"
  end

  create_table "console1984_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "reason"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["created_at"], name: "index_console1984_sessions_on_created_at"
    t.index ["user_id", "created_at"], name: "index_console1984_sessions_on_user_id_and_created_at"
  end

  create_table "console1984_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["username"], name: "index_console1984_users_on_username"
  end

  create_table "devices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "identifier", null: false
    t.string "name"
    t.uuid "owner_id"
    t.string "platform", null: false
    t.string "push_token"
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_devices_on_identifier", unique: true
    t.index ["owner_id"], name: "index_devices_on_owner_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.timestamptz "delivered_at"
    t.uuid "noticeable_id", null: false
    t.string "noticeable_type", null: false
    t.timestamptz "received_at"
    t.uuid "recipient_id", null: false
    t.datetime "updated_at", null: false
    t.index ["noticeable_type", "noticeable_id"], name: "index_notifications_on_noticeable"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "passkit_devices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "identifier", null: false
    t.string "push_token", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_passkit_devices_on_identifier", unique: true
  end

  create_table "passkit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "passkit_passes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "authentication_token", null: false
    t.datetime "created_at", null: false
    t.uuid "generator_id"
    t.string "generator_type"
    t.string "klass", null: false
    t.string "serial_number", null: false
    t.datetime "updated_at", null: false
    t.index ["generator_type", "generator_id"], name: "index_passkit_passes_on_generator"
    t.index ["serial_number"], name: "index_passkit_passes_on_serial_number", unique: true
  end

  create_table "passkit_registrations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "passkit_device_id", null: false
    t.uuid "passkit_pass_id", null: false
    t.datetime "updated_at", null: false
    t.index ["passkit_device_id"], name: "index_passkit_registrations_on_passkit_device_id"
    t.index ["passkit_pass_id", "passkit_device_id"], name: "index_passkit_registrations_uniqueness", unique: true
    t.index ["passkit_pass_id"], name: "index_passkit_registrations_on_passkit_pass_id"
  end

  create_table "phone_number_verification_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.inet "ip_address", null: false
    t.string "phone_number", null: false
    t.string "user_agent", null: false
    t.string "verification_code", null: false
    t.timestamptz "verified_at"
  end

  create_table "post_type_grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.uuid "post_type_id", null: false
    t.uuid "world_key_id", null: false
    t.index ["post_type_id"], name: "index_post_type_grants_on_post_type_id"
    t.index ["world_key_id", "post_type_id"], name: "index_post_type_grants_uniqueness", unique: true
    t.index ["world_key_id"], name: "index_post_type_grants_on_world_key_id"
  end

  create_table "post_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "icon"
    t.string "label", null: false
    t.datetime "updated_at", null: false
    t.uuid "world_id", null: false
    t.index ["world_id", "label"], name: "index_post_types_uniqueness", unique: true
    t.index ["world_id"], name: "index_post_types_on_world_id"
  end

  create_table "posts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "emoji"
    t.uuid "hidden_from_ids", default: [], null: false, array: true
    t.text "plain_body", null: false
    t.boolean "quiet", default: false, null: false
    t.string "title"
    t.uuid "type_id", null: false
    t.datetime "updated_at", null: false
    t.jsonb "v1_attributes"
    t.index ["hidden_from_ids"], name: "index_posts_on_hidden_from_ids", using: :gin
    t.index ["quiet"], name: "index_posts_on_quiet"
    t.index ["type_id"], name: "index_posts_on_type_id"
  end

  create_table "reactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.string "emoji", null: false
    t.uuid "post_id", null: false
    t.uuid "reactor_id", null: false
    t.index ["post_id", "emoji", "reactor_id"], name: "index_reactions_uniqueness", unique: true
    t.index ["post_id"], name: "index_reactions_on_post_id"
    t.index ["reactor_id"], name: "index_reactions_on_reactor_id"
  end

  create_table "reply_initiations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.string "platform", null: false
    t.uuid "post_id", null: false
    t.uuid "replier_id", null: false
    t.index ["post_id"], name: "index_reply_initiations_on_post_id"
    t.index ["replier_id"], name: "index_reply_initiations_on_replier_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "phone_number_verification_request_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["phone_number_verification_request_id"], name: "index_sessions_on_phone_number_verification_request_id"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.uuid "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "job_id", null: false
    t.uuid "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.uuid "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.uuid "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
    t.index ["version"], name: "index_task_records_on_version", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "has_v1_account", default: false, null: false
    t.string "name", null: false
    t.timestamptz "notifications_last_cleared_at"
    t.string "phone_number", null: false
    t.string "time_zone_name", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  create_table "world_cards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cardholder_id"
    t.datetime "created_at", null: false
    t.uuid "device_id"
    t.timestamptz "discarded_at"
    t.timestamptz "relevant_date", default: -> { "now()" }
    t.datetime "updated_at", null: false
    t.uuid "world_id", null: false
    t.uuid "world_key_id"
    t.index ["cardholder_id"], name: "index_world_cards_on_cardholder_id"
    t.index ["device_id"], name: "index_world_cards_on_device_id"
    t.index ["discarded_at"], name: "index_world_cards_on_discarded_at"
    t.index ["relevant_date"], name: "index_world_cards_on_relevant_date"
    t.index ["world_id"], name: "index_world_cards_on_world_id"
    t.index ["world_key_id"], name: "index_world_cards_on_world_key_id"
  end

  create_table "world_invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "granted_post_type_ids", default: [], null: false, array: true
    t.uuid "recipient_id"
    t.string "recipient_phone_number", null: false
    t.datetime "updated_at", null: false
    t.uuid "world_id", null: false
    t.index ["recipient_id"], name: "index_world_invitations_on_recipient_id"
    t.index ["world_id", "recipient_phone_number"], name: "index_world_invitations_uniqueness", unique: true
    t.index ["world_id"], name: "index_world_invitations_on_world_id"
  end

  create_table "world_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "invitation_id"
    t.uuid "recipient_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "world_id", null: false
    t.index ["invitation_id"], name: "index_world_keys_on_invitation_id"
    t.index ["recipient_id"], name: "index_world_keys_on_recipient_id"
    t.index ["world_id", "recipient_id"], name: "index_world_keys_uniqueness", unique: true
    t.index ["world_id"], name: "index_world_keys_on_world_id"
  end

  create_table "worlds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "blurb"
    t.datetime "created_at", null: false
    t.timestamptz "last_imported_v1_post_created_at"
    t.string "name", null: false
    t.uuid "owner_id", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "owner_id"], name: "index_worlds_on_name_and_owner_id", unique: true
    t.index ["owner_id"], name: "index_worlds_on_owner_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "devices", "users", column: "owner_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "passkit_registrations", "passkit_devices"
  add_foreign_key "passkit_registrations", "passkit_passes"
  add_foreign_key "post_type_grants", "post_types"
  add_foreign_key "post_type_grants", "world_keys"
  add_foreign_key "post_types", "worlds"
  add_foreign_key "posts", "post_types", column: "type_id"
  add_foreign_key "reactions", "posts"
  add_foreign_key "reactions", "users", column: "reactor_id"
  add_foreign_key "reply_initiations", "posts"
  add_foreign_key "reply_initiations", "users", column: "replier_id"
  add_foreign_key "sessions", "phone_number_verification_requests"
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "world_cards", "devices"
  add_foreign_key "world_cards", "users", column: "cardholder_id"
  add_foreign_key "world_cards", "world_keys"
  add_foreign_key "world_cards", "worlds"
  add_foreign_key "world_invitations", "users", column: "recipient_id"
  add_foreign_key "world_invitations", "worlds"
  add_foreign_key "world_keys", "users", column: "recipient_id"
  add_foreign_key "world_keys", "world_invitations", column: "invitation_id"
  add_foreign_key "world_keys", "worlds"
  add_foreign_key "worlds", "users", column: "owner_id"
end
