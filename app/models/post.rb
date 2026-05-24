# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: posts
#
#  id         :uuid             not null, primary key
#  plain_body :text             not null
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  world_id   :uuid             not null
#
# Indexes
#
#  index_posts_on_world_id  (world_id)
#
# Foreign Keys
#
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Post < ApplicationRecord
  include NormalizesText

  # == Associations ==

  belongs_to :world
  has_one :author, through: :world, source: :owner

  sig { returns(World) }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing associated world"
  end

  sig { returns(User) }
  def author!
    author or raise ActiveRecord::RecordNotFound, "Missing author"
  end

  # == Attachments

  has_rich_text :body
  has_many_attached :images do |attachable|
    attachable.variant(:thumbnail, resize_to_limit: [ 800, 800 ])
  end

  sig { returns(T::Array[T.any(ActiveStorage::VariantWithRecord, ActiveStorage::Blob)]) }
  def images_thumbnails
    images_attachments.map do |attachment|
      blob = attachment.blob or next
      if blob.content_type == "image/gif"
        blob
      else
        attachment.variant(:thumbnail)
      end
    end
  end

  # == Normalizations

  nilify_blanks :title

  # == Validations ==

  validates :body, presence: true
  validates :images,
    processable_file: true,
    limit: { max: 4 },
    content_type: {
      with: %r{\A(image|video)/[a-z]+\z},
      spoofing_protection: true,
    },
    size: { less_than: 64.megabytes }

  # == Hooks ==

  before_save :set_plain_body

  # == Snippets ==

  sig { returns(T.nilable(String)) }
  def title_snippet
    if (title = self.title)
      snip(title.strip.truncate(92))
    end
  end

  sig { returns(String) }
  def truncated_body_text
    body.to_plain_text.strip.truncate(120)
  end

  sig { returns(String) }
  def body_snippet
    snip(truncated_body_text.gsub("\n\n", "\n"))
  end

  sig { returns(String) }
  def snippet
    [ title_snippet, body_snippet ].compact.join("\n")
  end

  sig { returns(String) }
  def reply_snippet
    snippet + "\n\n"
  end

  sig { params(platform: Symbol).returns(String) }
  def reply_url(platform:)
    author!.dm_url(platform:, message: reply_snippet)
  end

  private

  # == Helpers ==

  sig { params(text: String).returns(String) }
  def snip(text)
    "> " + text.split("\n").join("\n> ")
  end

  # == Callbacks ==

  sig { void }
  def set_plain_body
    self.plain_body = rich_text_body.to_plain_text
  end
end
