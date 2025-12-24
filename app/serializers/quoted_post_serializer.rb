# typed: true
# frozen_string_literal: true

class QuotedPostSerializer < ApplicationSerializer
  # == Configuration ==

  object_as :post

  # == Attributes ==

  identifier
  attributes :created_at,
             :title,
             :emoji,
             :pinned_until,
             type: { type: "PostType" }

  attribute :body_html, type: :string do
    if (body_html = post.body_html)
      body_html
    else
      post.rich_text_body.to_trix_html
    end
  end

  # == Associations ==

  has_many :ordered_images, as: :images, serializer: ImageSerializer
end
