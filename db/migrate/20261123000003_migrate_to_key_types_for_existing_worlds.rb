# frozen_string_literal: true

class MigrateToKeyTypesForExistingWorlds < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      CREATE TABLE cutover_world_keys AS SELECT id, type_id FROM world_keys;
      CREATE TABLE cutover_invitations AS SELECT id, key_type_id FROM world_invitations;
      CREATE TABLE cutover_posts AS SELECT id, visible_to_key_type_ids, visible_to_user_ids FROM posts;
      CREATE TABLE cutover_pending_worlds AS SELECT id FROM worlds WHERE NOT key_types_review_pending;

      CREATE TABLE cutover_key_types (id uuid PRIMARY KEY, previous_color varchar);
      WITH starters(name, color) AS (
        VALUES ('chosen family', 'pink'), ('new friends', 'green'),
               ('acquaintances', 'blue'), ('existing friends', 'orange')
      ), inserted AS (
        INSERT INTO world_key_types (world_id, name, color, created_at, updated_at)
        SELECT worlds.id, starters.name, starters.color, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        FROM worlds CROSS JOIN starters
        ON CONFLICT (world_id, name) DO NOTHING
        RETURNING id
      ), recolored AS (
        SELECT types.id, types.color AS previous_color, starters.color
        FROM world_key_types types JOIN starters USING (name)
        WHERE types.color <> starters.color
      ), corrected AS (
        UPDATE world_key_types types SET color = recolored.color
        FROM recolored WHERE types.id = recolored.id
        RETURNING types.id, recolored.previous_color
      )
      INSERT INTO cutover_key_types
      SELECT id, NULL FROM inserted UNION ALL SELECT id, previous_color FROM corrected;

      UPDATE world_keys SET type_id = types.id
      FROM world_key_types types
      WHERE types.world_id = world_keys.world_id AND types.name = 'existing friends';

      UPDATE world_invitations SET key_type_id = types.id
      FROM world_key_types types
      WHERE types.world_id = world_invitations.world_id AND types.name = 'existing friends';

      WITH holders AS (
        SELECT grants.world_id, grants.post_type_id,
               array_agg(DISTINCT keys.recipient_id ORDER BY keys.recipient_id) AS user_ids
        FROM post_type_grants grants
        JOIN world_keys keys ON (keys.world_id, keys.id) = (grants.world_id, grants.world_key_id)
        GROUP BY grants.world_id, grants.post_type_id
      )
      UPDATE posts SET visible_to_key_type_ids = '{}', visible_to_user_ids = COALESCE(holders.user_ids, '{}')
      FROM post_types LEFT JOIN holders ON (holders.world_id, holders.post_type_id) = (post_types.world_id, post_types.id)
      WHERE (posts.world_id, posts.type_id) = (post_types.world_id, post_types.id);

      UPDATE worlds SET key_types_review_pending = TRUE WHERE NOT key_types_review_pending;
      ALTER TABLE world_keys ALTER COLUMN type_id SET NOT NULL;
      ALTER TABLE world_invitations ALTER COLUMN key_type_id SET NOT NULL;
    SQL
  end

  # Only while writers are still stopped. New-release writes require separate recovery.
  def down
    execute <<~SQL.squish
      ALTER TABLE world_keys ALTER COLUMN type_id DROP NOT NULL;
      ALTER TABLE world_invitations ALTER COLUMN key_type_id DROP NOT NULL;

      UPDATE world_keys SET type_id = saved.type_id FROM cutover_world_keys saved WHERE world_keys.id = saved.id;
      UPDATE world_invitations SET key_type_id = saved.key_type_id
      FROM cutover_invitations saved WHERE world_invitations.id = saved.id;
      UPDATE posts SET visible_to_key_type_ids = saved.visible_to_key_type_ids, visible_to_user_ids = saved.visible_to_user_ids
      FROM cutover_posts saved WHERE posts.id = saved.id;
      UPDATE worlds SET key_types_review_pending = FALSE WHERE id IN (SELECT id FROM cutover_pending_worlds);
      UPDATE world_key_types SET color = saved.previous_color FROM cutover_key_types saved
      WHERE world_key_types.id = saved.id AND saved.previous_color IS NOT NULL;
      DELETE FROM world_key_types WHERE id IN (SELECT id FROM cutover_key_types WHERE previous_color IS NULL);

      DROP TABLE cutover_world_keys, cutover_invitations, cutover_posts, cutover_pending_worlds, cutover_key_types;
    SQL
  end
end
