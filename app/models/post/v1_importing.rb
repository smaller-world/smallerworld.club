# typed: strict
# frozen_string_literal: true

module Post::V1Importing
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { Post }

  # == Methods ==

  sig { returns(T.nilable(V1::Post)) }
  def v1_post
    V1::Post.find_by(id:)
  end

  sig { params(v1_post: V1::Post).returns(TrueClass) }
  def update_from_v1_post!(v1_post)
    transaction do
      images = v1_post.open_ordered_images do |files|
        files.map do |file|
          ActiveStorage::Blob.create_and_upload!(
            io: file,
            filename: File.basename(file.to_path),
          )
        end
      end
      update!(
        **v1_post.attributes.slice("created_at", "updated_at", "title", "emoji"),
        body: v1_post.body_html,
        images:,
        key_colors: v1_post.visibility == "private" ? [] : nil,
        v1_type: v1_post.type,
        v1_visibility: v1_post.visibility,
        v1_pinned_until: v1_post.pinned_until,
        v1_spotify_track_id: v1_post.spotify_track_id,
      )
    end
  end

  sig { returns(T::Boolean) }
  def reimport_from_v1_post!
    if (v1_post = self.v1_post)
      update_from_v1_post!(v1_post)
    else
      false
    end
  end
end
