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

ActiveRecord::Schema[8.1].define(version: 2026_03_22_192453) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "postgis"

  create_table "action_push_native_devices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "installation_id", null: false
    t.string "name"
    t.uuid "owner_id", null: false
    t.string "platform", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["installation_id", "owner_id"], name: "index_action_push_native_devices_uniqueness", unique: true
    t.index ["owner_id"], name: "index_action_push_native_devices_on_owner_id"
  end

  create_table "action_text_rich_texts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body"
    t.timestamp "created_at", precision: 6, null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.timestamp "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
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

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "deprecated_user_id"
    t.text "description", null: false
    t.string "emoji"
    t.string "location_name", null: false
    t.string "name", null: false
    t.string "template_id"
    t.datetime "updated_at", null: false
    t.uuid "world_id", null: false
    t.index ["deprecated_user_id"], name: "index_activities_on_deprecated_user_id"
    t.index ["world_id", "template_id"], name: "index_activities_uniqueness", unique: true
    t.index ["world_id"], name: "index_activities_on_world_id"
  end

  create_table "activity_coupons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", precision: nil, null: false
    t.uuid "friend_id", null: false
    t.datetime "redeemed_at", precision: nil
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_activity_coupons_on_activity_id"
    t.index ["expires_at"], name: "index_activity_coupons_on_expires_at"
    t.index ["friend_id"], name: "index_activity_coupons_on_friend_id"
    t.index ["redeemed_at"], name: "index_activity_coupons_on_redeemed_at"
  end

  create_table "announcements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "message", null: false
    t.string "test_recipient_phone_number"
  end

  create_table "encouragements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "emoji", null: false
    t.uuid "friend_id", null: false
    t.text "message", null: false
    t.index ["created_at"], name: "index_encouragements_on_created_at"
    t.index ["friend_id"], name: "index_encouragements_on_friend_id"
  end

  create_table "friends", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "access_token", null: false
    t.boolean "chosen_family", null: false
    t.datetime "created_at", null: false
    t.uuid "deprecated_join_request_id"
    t.uuid "deprecated_user_id"
    t.string "emoji"
    t.uuid "invitation_id"
    t.string "name", null: false
    t.datetime "notifications_last_cleared_at", precision: nil
    t.datetime "paused_since", precision: nil
    t.string "phone_number"
    t.string "subscribed_post_types", null: false, array: true
    t.string "time_zone_name", null: false
    t.datetime "updated_at", null: false
    t.uuid "world_id", null: false
    t.index ["access_token"], name: "index_friends_on_access_token", unique: true
    t.index ["deprecated_user_id"], name: "index_friends_on_deprecated_user_id"
    t.index ["invitation_id"], name: "index_friends_on_invitation_id"
    t.index ["notifications_last_cleared_at"], name: "index_friends_on_notifications_last_cleared_at"
    t.index ["phone_number"], name: "index_friends_on_phone_number"
    t.index ["world_id", "name"], name: "index_friends_name_uniqueness", unique: true
    t.index ["world_id", "phone_number"], name: "index_friends_phone_number_uniqueness", unique: true
    t.index ["world_id"], name: "index_friends_on_world_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "deprecated_user_id"
    t.string "invitee_emoji"
    t.string "invitee_name", null: false
    t.uuid "join_request_id"
    t.uuid "offered_activity_ids", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.uuid "world_id", null: false
    t.index ["deprecated_user_id"], name: "index_invitations_on_deprecated_user_id"
    t.index ["join_request_id"], name: "index_invitations_on_join_request_id"
    t.index ["world_id", "invitee_name"], name: "index_invitations_invitee_name_uniqueness", unique: true
    t.index ["world_id"], name: "index_invitations_on_world_id"
  end

  create_table "join_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "deprecated_user_id"
    t.string "name", null: false
    t.string "phone_number", null: false
    t.datetime "updated_at", null: false
    t.uuid "world_id", null: false
    t.index ["deprecated_user_id"], name: "index_join_requests_on_deprecated_user_id"
    t.index ["world_id", "phone_number"], name: "index_join_requests_uniqueness", unique: true
    t.index ["world_id"], name: "index_join_requests_on_world_id"
  end

  create_table "login_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", null: false
    t.inet "ip_address"
    t.string "login_code", null: false
    t.string "phone_number", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_at"], name: "index_login_requests_on_completed_at"
    t.index ["created_at", "ip_address"], name: "index_login_requests_on_created_at_and_ip_address"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "delivered_at", precision: nil
    t.string "deprecated_delivery_token"
    t.uuid "noticeable_id", null: false
    t.string "noticeable_type", null: false
    t.datetime "pushed_at", precision: nil
    t.uuid "recipient_id"
    t.string "recipient_type"
    t.datetime "updated_at", null: false
    t.index ["deprecated_delivery_token"], name: "index_notifications_on_deprecated_delivery_token", unique: true
    t.index ["noticeable_type", "noticeable_id"], name: "index_notifications_on_noticeable"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "post_reactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "deprecated_friend_id"
    t.string "emoji", null: false
    t.uuid "post_id", null: false
    t.uuid "reactor_id", null: false
    t.string "reactor_type", null: false
    t.index ["deprecated_friend_id"], name: "index_post_reactions_on_deprecated_friend_id"
    t.index ["post_id"], name: "index_post_reactions_on_post_id"
    t.index ["reactor_type", "reactor_id", "post_id", "emoji"], name: "index_post_reactions_uniqueness", unique: true
    t.index ["reactor_type", "reactor_id"], name: "index_post_reactions_on_reactor"
  end

  create_table "post_reply_receipts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "deprecated_friend_id"
    t.uuid "post_id", null: false
    t.uuid "replier_id", null: false
    t.string "replier_type", null: false
    t.index ["deprecated_friend_id"], name: "index_post_reply_receipts_on_deprecated_friend_id"
    t.index ["post_id"], name: "index_post_reply_receipts_on_post_id"
    t.index ["replier_type", "replier_id"], name: "index_post_reply_receipts_on_replier"
  end

  create_table "post_shares", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "post_id", null: false
    t.uuid "sharer_id", null: false
    t.string "sharer_type", null: false
    t.index ["post_id", "sharer_id", "sharer_type"], name: "index_post_shares_uniqueness", unique: true
    t.index ["post_id"], name: "index_post_shares_on_post_id"
    t.index ["sharer_type", "sharer_id"], name: "index_post_shares_on_sharer"
  end

  create_table "post_stickers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "emoji", null: false
    t.uuid "friend_id", null: false
    t.uuid "post_id", null: false
    t.float "relative_position_x", null: false
    t.float "relative_position_y", null: false
    t.index ["emoji"], name: "index_post_stickers_on_emoji"
    t.index ["friend_id"], name: "index_post_stickers_on_friend_id"
    t.index ["post_id"], name: "index_post_stickers_on_post_id"
  end

  create_table "post_views", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "deprecated_friend_id"
    t.uuid "post_id", null: false
    t.uuid "viewer_id", null: false
    t.string "viewer_type", null: false
    t.index ["deprecated_friend_id"], name: "index_post_views_on_deprecated_friend_id"
    t.index ["post_id"], name: "index_post_views_on_post_id"
    t.index ["viewer_type", "viewer_id", "post_id"], name: "index_post_views_uniqueness", unique: true
  end

  create_table "posts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "author_id", null: false
    t.text "body_html"
    t.datetime "created_at", null: false
    t.string "emoji"
    t.uuid "encouragement_id"
    t.uuid "hidden_from_ids", default: [], null: false, array: true
    t.uuid "images_ids", default: [], null: false, array: true
    t.string "pen_name"
    t.datetime "pinned_until", precision: nil
    t.string "prompt_id"
    t.uuid "quoted_post_id"
    t.geography "secret_location", limit: {srid: 4326, type: "st_point", geographic: true}
    t.uuid "space_id"
    t.string "spotify_track_id"
    t.string "title"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.string "visibility", null: false
    t.uuid "visible_to_ids", default: [], null: false, array: true
    t.uuid "world_id"
    t.index "(((to_tsvector('simple'::regconfig, COALESCE((emoji)::text, ''::text)) || to_tsvector('simple'::regconfig, COALESCE((title)::text, ''::text))) || to_tsvector('simple'::regconfig, COALESCE(body_html, ''::text))))", name: "index_posts_for_search", using: :gin
    t.index ["author_id", "created_at"], name: "index_posts_on_author_id_and_created_at"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["encouragement_id"], name: "index_posts_on_encouragement_id", unique: true
    t.index ["hidden_from_ids"], name: "index_posts_on_hidden_from_ids", using: :gin
    t.index ["pinned_until"], name: "index_posts_on_pinned_until"
    t.index ["prompt_id"], name: "index_posts_on_prompt_id"
    t.index ["quoted_post_id"], name: "index_posts_on_quoted_post_id"
    t.index ["space_id"], name: "index_posts_on_space_id"
    t.index ["type"], name: "index_posts_on_type"
    t.index ["visibility"], name: "index_posts_on_visibility"
    t.index ["visible_to_ids"], name: "index_posts_on_visible_to_ids", using: :gin
    t.index ["world_id"], name: "index_posts_on_world_id"
  end

  create_table "push_registrations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "deprecated_service_worker_version"
    t.string "device_fingerprint", null: false
    t.float "device_fingerprint_confidence", limit: 24, null: false
    t.uuid "device_id", null: false
    t.uuid "owner_id"
    t.string "owner_type"
    t.uuid "push_subscription_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["device_fingerprint"], name: "index_push_registrations_on_device_fingerprint"
    t.index ["device_id"], name: "index_push_registrations_on_device_id"
    t.index ["owner_type", "owner_id", "push_subscription_id"], name: "index_push_registrations_uniqueness", unique: true
    t.index ["owner_type", "owner_id"], name: "index_push_registrations_on_owner"
    t.index ["push_subscription_id"], name: "index_push_registrations_on_push_subscription_id"
  end

  create_table "push_subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "auth_key", null: false
    t.datetime "created_at", null: false
    t.string "endpoint", null: false
    t.string "p256dh_key", null: false
    t.integer "service_worker_version"
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.inet "ip_address", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "spaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "name", null: false
    t.uuid "owner_id", null: false
    t.boolean "public", default: false, null: false
    t.string "theme"
    t.datetime "updated_at", null: false
    t.index ["owner_id", "name"], name: "index_spaces_owner_name_uniqueness", unique: true
    t.index ["owner_id"], name: "index_spaces_on_owner_id"
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "text_blasts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "friend_id", null: false
    t.string "phone_number", null: false
    t.uuid "post_id", null: false
    t.datetime "sent_at", precision: nil
    t.index ["friend_id"], name: "index_text_blasts_on_friend_id"
    t.index ["post_id"], name: "index_text_blasts_on_post_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "allow_space_replies", default: true, null: false
    t.datetime "created_at", null: false
    t.boolean "deprecated_allow_friend_sharing"
    t.string "deprecated_handle"
    t.boolean "deprecated_hide_neko"
    t.boolean "deprecated_hide_stats"
    t.string "deprecated_reply_to_number"
    t.string "deprecated_theme"
    t.string "membership_tier"
    t.string "name", null: false
    t.datetime "notifications_last_cleared_at", precision: nil
    t.string "phone_number", null: false
    t.string "time_zone_name", null: false
    t.datetime "updated_at", null: false
    t.index ["deprecated_handle"], name: "index_users_on_deprecated_handle", unique: true
    t.index ["membership_tier"], name: "index_users_on_membership_tier"
    t.index ["notifications_last_cleared_at"], name: "index_users_on_notifications_last_cleared_at"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  create_table "worlds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "allow_friend_sharing", default: true, null: false
    t.datetime "created_at", null: false
    t.string "handle", null: false
    t.boolean "hide_neko", default: false, null: false
    t.boolean "hide_stats", default: false, null: false
    t.uuid "owner_id", null: false
    t.string "reply_to_number_override"
    t.string "theme"
    t.datetime "updated_at", null: false
    t.index ["handle"], name: "index_worlds_on_handle", unique: true
    t.index ["owner_id"], name: "index_worlds_on_owner_id"
  end

  add_foreign_key "action_push_native_devices", "users", column: "owner_id"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "users", column: "deprecated_user_id"
  add_foreign_key "activities", "worlds"
  add_foreign_key "activity_coupons", "activities"
  add_foreign_key "activity_coupons", "friends"
  add_foreign_key "encouragements", "friends"
  add_foreign_key "friends", "invitations"
  add_foreign_key "friends", "users", column: "deprecated_user_id"
  add_foreign_key "friends", "worlds"
  add_foreign_key "invitations", "users", column: "deprecated_user_id"
  add_foreign_key "invitations", "worlds"
  add_foreign_key "join_requests", "users", column: "deprecated_user_id"
  add_foreign_key "join_requests", "worlds"
  add_foreign_key "post_reactions", "posts"
  add_foreign_key "post_reply_receipts", "posts"
  add_foreign_key "post_shares", "posts"
  add_foreign_key "post_stickers", "friends"
  add_foreign_key "post_stickers", "posts"
  add_foreign_key "post_views", "posts"
  add_foreign_key "posts", "encouragements"
  add_foreign_key "posts", "posts", column: "quoted_post_id"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "posts", "worlds"
  add_foreign_key "push_registrations", "push_subscriptions"
  add_foreign_key "sessions", "users"
  add_foreign_key "spaces", "users", column: "owner_id"
  add_foreign_key "text_blasts", "friends"
  add_foreign_key "text_blasts", "posts"
  add_foreign_key "worlds", "users", column: "owner_id"
end
