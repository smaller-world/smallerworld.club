# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: posts
#
#  id         :uuid             not null, primary key
#  emoji      :string
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
  has_many :world_cards, through: :world, source: :cards
  has_one :author, through: :world, source: :owner
  has_many :reactions, dependent: :destroy
  has_many :reply_initiations, dependent: :destroy

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
  def image_thumbnails
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

  strips_text :title
  nilify_blanks :title, :emoji

  # == Validations ==

  validates :emoji, emoji: true, allow_nil: true
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
  after_commit :touch_world_cards, on: [ :create, :destroy ]

  # == Emoji ==

  sig { returns(T.nilable(String)) }
  def fun_title
    [ emoji, title ].compact.presence&.join(" ")
  end

  # == Snippets ==

  sig { returns(T.nilable(String)) }
  def title_snippet
    if (title = fun_title)
      title.strip.truncate(92)
    end
  end

  sig { returns(String) }
  def body_snippet
    plain_body.strip.truncate(120)
  end

  sig { returns(String) }
  def snippet
    [ title_snippet, body_snippet ].compact.join("\n")
  end

  sig { returns(String) }
  def card_snippet
    text = title_snippet || T.must(body_snippet.lines.first)
    text.strip.truncate(36)
  end

  sig { params(platform: Symbol).returns(String) }
  def reply_snippet_for(platform)
    if platform == :whatsapp
      "> " + snippet.gsub("\n", "\n>\u2800") + "\n\n\u2800"
    else
      "> " + snippet.gsub("\n", "\n> ") + "\n\n"
    end
  end

  sig { params(platform: Symbol, native: T::Boolean).returns(String) }
  def reply_url(platform:, native: false)
    message = reply_snippet_for(platform)
    author!.dm_url(platform:, message:, native:)
  end

  private

  # == Callbacks ==

  sig { void }
  def set_plain_body
    self.plain_body = rich_text_body.to_plain_text.gsub("\n\n", "\n")
  end

  # == Callbacks ==

  sig { void }
  def touch_world_cards
    world_cards.find_each(&:touch)
  end
end
