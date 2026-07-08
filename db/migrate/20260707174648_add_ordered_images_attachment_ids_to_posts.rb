# typed: true
# frozen_string_literal: true

class AddOrderedImagesAttachmentIdsToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts,
      :ordered_images_attachment_ids,
      :uuid,
      array: true,
      default: [],
      null: false
    up_only do
      execute <<~SQL.squish
        UPDATE posts
        SET ordered_images_attachment_ids = ordered.attachment_ids
        FROM (
          SELECT
            record_id AS post_id,
            array_agg(id ORDER BY created_at ASC, id ASC) AS attachment_ids
          FROM active_storage_attachments
          WHERE record_type = 'Post' AND name = 'images'
          GROUP BY record_id
        ) AS ordered
        WHERE posts.id = ordered.post_id
      SQL
    end
  end
end
