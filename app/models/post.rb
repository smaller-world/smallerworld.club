# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: posts
#
#  id         :uuid             not null, primary key
#  emoji      :string
#  key_colors :string           is an Array
#  plain_body :text             not null
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  world_id   :uuid             not null
#
# Indexes
#
#  index_posts_on_key_colors  (key_colors)
#  index_posts_on_world_id    (world_id)
#
# Foreign Keys
#
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Post < ApplicationRecord
  include Noticeable
  include NormalizesText
  include NormalizesArrays

  # == Attributes ==

  encrypts :plain_body, deterministic: true, previous: { deterministic: false }

  sig { returns(T::Boolean) }
  def selectively_shown?
    !key_colors.nil?
  end

  # == Associations ==

  belongs_to :world
  has_many :world_cards, through: :world, source: :cards
  has_one :author, through: :world, source: :owner
  has_many :world_key_recipients, through: :world, source: :key_recipients

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

  # == Scopes ==

  scope :visible_to, ->(user) {
    owned = World.where(owner: user).where("worlds.id = posts.world_id")
    keyed = WorldKey.accepted.where(recipient: user)
      .where("world_keys.world_id = posts.world_id")
      .where("posts.key_colors IS NULL OR world_keys.color = ANY (posts.key_colors)")
    where(owned.arel.exists.or(keyed.arel.exists))
  }

  # == Attachments

  has_rich_text :body, encrypted: true
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
  compacts_blanks :key_colors

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
  validates :key_colors, inclusion: { in: WorldKey.color.values }, allow_nil: true

  # == Hooks ==

  before_validation :unset_key_colors, if: :all_key_colors_set?
  before_save :set_plain_body
  after_commit :touch_world_cards, on: [ :create, :destroy ]
  after_create_commit :create_notifications_for_world_key_recipients!

  # == Noticeable ==

  sig { override.params(recipient: User).returns(Notification::Message) }
  def notification_message(recipient:)
    world = world!
    Notification::Message.new(
      target_url: world,
      title: world.name,
      body: snippet,
      world:,
    )
  end

  sig { void }
  def create_notifications_for_world_key_recipients!
    keys = world!.keys.accepted
    if (colors = key_colors)
      keys = keys.where(color: colors)
    end
    keys.find_each do |key|
      notifications.create!(recipient: key.recipient!)
    end
  end

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

  # == Helpers ==

  sig { returns(T::Boolean) }
  def all_key_colors_set?
    if (colors = key_colors)
      colors.to_set == WorldKey.color.values.to_set
    else
      false
    end
  end

  # == Callbacks ==

  sig { void }
  def set_plain_body
    self.plain_body = rich_text_body.to_plain_text.gsub("\n\n", "\n")
  end

  sig { void }
  def touch_world_cards
    world_cards.find_each(&:touch)
  end

  sig { void }
  def unset_key_colors
    self.key_colors = nil
  end
end
