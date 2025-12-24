# typed: true
# frozen_string_literal: true

class PostSerializer < ApplicationSerializer
  # == Attributes ==

  identifier
  attributes :created_at,
             :title,
             :emoji,
             :pinned_until,
             :spotify_track_id,
             :world_id,
             :space_id,
             type: { type: "PostType" },
             visibility: { type: "PostVisibility" },
             snippet: { type: :string },
             reply_snippet: { type: :string }

  attribute :author_id, type: :string, nullable: true do
    post.author_id unless post.pen_name?
  end

  attribute :body_html, type: :string do
    if (body_html = post.body_html)
      body_html
    else
      post.rich_text_body.to_trix_html
    end
  end

  # == Associations ==

  has_many :ordered_images, as: :images, serializer: ImageSerializer
  has_one :quoted_post, serializer: QuotedPostSerializer, nullable: true
  has_one :encouragement,
          serializer: PostEncouragementSerializer,
          nullable: true
  has_one :prompt, serializer: PostPromptSerializer, nullable: true
end
