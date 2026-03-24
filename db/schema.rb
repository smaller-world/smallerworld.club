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

ActiveRecord::Schema[8.1].define(version: 2026_03_23_160515) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "postgis"

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

  create_table "ai_chat_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "cache_creation_tokens"
    t.integer "cached_tokens"
    t.uuid "chat_id", null: false
    t.text "content"
    t.json "content_raw"
    t.datetime "created_at", null: false
    t.integer "input_tokens"
    t.uuid "model_id"
    t.integer "output_tokens"
    t.string "role", null: false
    t.text "thinking_signature"
    t.text "thinking_text"
    t.integer "thinking_tokens"
    t.uuid "tool_call_id"
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_ai_chat_messages_on_chat_id"
    t.index ["model_id"], name: "index_ai_chat_messages_on_model_id"
    t.index ["role"], name: "index_ai_chat_messages_on_role"
    t.index ["tool_call_id"], name: "index_ai_chat_messages_on_tool_call_id"
  end

  create_table "ai_chats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "model_id"
    t.datetime "updated_at", null: false
    t.index ["model_id"], name: "index_ai_chats_on_model_id"
  end

  create_table "ai_models", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "capabilities", default: []
    t.integer "context_window"
    t.datetime "created_at", null: false
    t.string "family"
    t.date "knowledge_cutoff"
    t.integer "max_output_tokens"
    t.jsonb "metadata", default: {}
    t.jsonb "modalities", default: {}
    t.datetime "model_created_at"
    t.string "model_id", null: false
    t.string "name", null: false
    t.jsonb "pricing", default: {}
    t.string "provider", null: false
    t.datetime "updated_at", null: false
    t.index ["capabilities"], name: "index_ai_models_on_capabilities", using: :gin
    t.index ["family"], name: "index_ai_models_on_family"
    t.index ["modalities"], name: "index_ai_models_on_modalities", using: :gin
    t.index ["provider", "model_id"], name: "index_ai_models_on_provider_and_model_id", unique: true
    t.index ["provider"], name: "index_ai_models_on_provider"
  end

  create_table "ai_tool_calls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "arguments", default: {}
    t.datetime "created_at", null: false
    t.uuid "message_id", null: false
    t.string "name", null: false
    t.string "thought_signature"
    t.string "tool_call_id", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_ai_tool_calls_on_message_id"
    t.index ["name"], name: "index_ai_tool_calls_on_name"
    t.index ["tool_call_id"], name: "index_ai_tool_calls_on_tool_call_id", unique: true
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.text "description_md", null: false
    t.tstzrange "duration", null: false
    t.jsonb "geo_address"
    t.geography "geo_location", limit: {srid: 4326, type: "st_point", geographic: true}
    t.string "luma_id", null: false
    t.string "luma_url", null: false
    t.string "name", null: false
    t.string "tag_ids", default: [], null: false, array: true
    t.string "time_zone_name", null: false
    t.datetime "updated_at", null: false
    t.index ["luma_id"], name: "index_events_on_luma_id", unique: true
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
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
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "webhook_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.jsonb "data", null: false
    t.string "event", null: false
    t.timestamptz "timestamp", null: false
    t.index ["timestamp"], name: "index_webhook_messages_on_timestamp"
  end

  create_table "whatsapp_group_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "admin"
    t.datetime "created_at", null: false
    t.uuid "group_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["group_id", "user_id"], name: "index_whatsapp_group_memberships_uniqueness", unique: true
    t.index ["group_id"], name: "index_whatsapp_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_whatsapp_group_memberships_on_user_id"
  end

  create_table "whatsapp_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.timestamptz "intro_sent_at"
    t.string "jid", null: false
    t.timestamptz "memberships_imported_at"
    t.timestamptz "message_history_enabled_at", null: false
    t.integer "message_history_window_days"
    t.timestamptz "metadata_imported_at"
    t.string "profile_picture_url"
    t.string "subject"
    t.datetime "updated_at", null: false
    t.index "((setweight(to_tsvector('simple'::regconfig, (COALESCE(subject, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('simple'::regconfig, COALESCE(description, ''::text)), 'B'::\"char\")))", name: "index_whatsapp_groups_on_subject_description_tsearch", using: :gin
    t.index ["intro_sent_at"], name: "index_whatsapp_groups_on_intro_sent_at"
    t.index ["jid"], name: "index_whatsapp_groups_on_jid", unique: true
    t.index ["memberships_imported_at"], name: "index_whatsapp_groups_on_memberships_imported_at"
    t.index ["metadata_imported_at"], name: "index_whatsapp_groups_on_metadata_imported_at"
  end

  create_table "whatsapp_message_mentions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "mentioned_user_id", null: false
    t.uuid "message_id", null: false
    t.datetime "updated_at", null: false
    t.index ["mentioned_user_id"], name: "index_whatsapp_message_mentions_on_mentioned_user_id"
    t.index ["message_id"], name: "index_whatsapp_message_mentions_on_message_id"
  end

  create_table "whatsapp_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.uuid "group_id", null: false
    t.string "mentioned_jids", default: [], null: false, array: true
    t.text "quoted_message_body"
    t.uuid "quoted_message_id"
    t.string "quoted_participant_jid"
    t.timestamptz "reply_sent_at"
    t.uuid "sender_id", null: false
    t.timestamptz "timestamp", null: false
    t.datetime "updated_at", null: false
    t.string "whatsapp_id", null: false
    t.index "to_tsvector('simple'::regconfig, COALESCE(body, ''::text))", name: "index_whatsapp_messages_on_body_tsearch", using: :gin
    t.index ["group_id"], name: "index_whatsapp_messages_on_group_id"
    t.index ["quoted_message_id"], name: "index_whatsapp_messages_on_quoted_message_id"
    t.index ["reply_sent_at"], name: "index_whatsapp_messages_on_reply_sent_at"
    t.index ["sender_id"], name: "index_whatsapp_messages_on_sender_id"
    t.index ["timestamp"], name: "index_whatsapp_messages_on_timestamp"
  end

  create_table "whatsapp_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "lid", null: false
    t.timestamptz "metadata_imported_at"
    t.string "phone_number"
    t.string "phone_number_jid"
    t.string "profile_picture_url"
    t.datetime "updated_at", null: false
    t.index ["lid"], name: "index_whatsapp_users_on_lid", unique: true
    t.index ["metadata_imported_at"], name: "index_whatsapp_users_on_metadata_imported_at"
    t.index ["phone_number"], name: "index_whatsapp_users_on_phone_number", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ai_chat_messages", "ai_chats", column: "chat_id"
  add_foreign_key "ai_chat_messages", "ai_models", column: "model_id"
  add_foreign_key "ai_chat_messages", "ai_tool_calls", column: "tool_call_id"
  add_foreign_key "ai_chats", "ai_models", column: "model_id"
  add_foreign_key "ai_tool_calls", "ai_chat_messages", column: "message_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "whatsapp_group_memberships", "whatsapp_groups", column: "group_id"
  add_foreign_key "whatsapp_group_memberships", "whatsapp_users", column: "user_id"
  add_foreign_key "whatsapp_message_mentions", "whatsapp_messages", column: "message_id"
  add_foreign_key "whatsapp_message_mentions", "whatsapp_users", column: "mentioned_user_id"
  add_foreign_key "whatsapp_messages", "whatsapp_groups", column: "group_id"
  add_foreign_key "whatsapp_messages", "whatsapp_messages", column: "quoted_message_id"
  add_foreign_key "whatsapp_messages", "whatsapp_users", column: "sender_id"
end
