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

  sig do
    params(v1_post: V1::Post, images: T::Array[ActiveStorage::Blob]).returns(TrueClass)
  end
  def update_from_v1_post!(v1_post, images: v1_post.import_ordered_images)
    update!(
      **v1_post.attributes.slice("created_at", "updated_at", "title", "emoji"),
      body: v1_post.body_html,
      images:,
      v1_type: v1_post.type,
      v1_visibility: v1_post.visibility,
      v1_pinned_until: v1_post.pinned_until,
      v1_spotify_track_id: v1_post.spotify_track_id,
    )
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
