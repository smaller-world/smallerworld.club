# typed: true
# frozen_string_literal: true

class BackfillDefaultPostTypes < ActiveRecord::Migration[8.1]
  def change
    up_only do
      execute <<~SQL.squish
        INSERT INTO post_types (id, world_id, label, icon, created_at, updated_at)
        SELECT gen_random_uuid(), worlds.id, defaults.label, defaults.icon, now(), now()
        FROM worlds
        CROSS JOIN (
          VALUES
            ('journal entry', 'huge/book-edit'),
            ('poem', 'huge/quill-write-01'),
            ('invitation', 'huge/mail-open-love'),
            ('ask', 'huge/waving-hand-02')
        ) AS defaults (label, icon)
        ON CONFLICT (world_id, label) DO NOTHING;
      SQL
    end
  end
end
