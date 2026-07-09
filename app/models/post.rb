# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: posts
#
#  id                            :uuid             not null, primary key
#  emoji                         :string
#  hidden_from_ids               :uuid             default([]), not null, is an Array
#  ordered_images_attachment_ids :uuid             default([]), not null, is an Array
#  plain_body                    :text             not null
#  quiet                         :boolean          default(FALSE), not null
#  title                         :string
#  v1_attributes                 :jsonb
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  type_id                       :uuid             not null
#
# Indexes
#
#  index_posts_on_hidden_from_ids         (hidden_from_ids) USING gin
#  index_posts_on_quiet                   (quiet)
#  index_posts_on_type_id_and_created_at  (type_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (type_id => post_types.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Post < ApplicationRecord
  include NormalizesText
  include NormalizesArrays
  include Noticeable
  include ReplyUrl
  include WorldItemBroadcasts
  include V1Importing

  # == Configuration ==

  NOTIFICATION_DELIVERY_DELAY = T.let(1.minute, ActiveSupport::Duration)

  # == Attributes ==

  typed_store(
    :v1_attributes,
    prefix: :v1,
    coder: ActiveRecord::TypedStore::IdentityCoder,
  ) do |s|
    s.string(:type)
    s.string(:visibility)
    s.datetime(:pinned_until)
    s.string(:quoted_post_id)
    s.string(:spotify_track_id)
  end

  encrypts :title, :plain_body

  sig { returns(T::Boolean) }
  def loud? = !quiet?

  sig { returns(T.nilable(String)) }
  def fun_title
    [ emoji, title ].compact.presence&.join(" ")
  end

  sig { returns(String) }
  def content
    [ fun_title, plain_body ].compact.join("\n\n")
  end

  # == Associations ==

  belongs_to :type, class_name: "PostType"
  has_many :type_recipients, through: :type, source: :recipients

  has_one :world, through: :type
  has_many :world_cards, through: :world, source: :cards
  has_many :world_keys, through: :world, source: :keys
  has_many :world_post_types, through: :world, source: :post_types
  has_one :world_owner, through: :world, source: :owner

  has_many :reactions, dependent: :destroy
  has_many :reply_initiations, dependent: :destroy

  sig { returns(PostType) }
  def type!
    type or raise ActiveRecord::RecordNotFound, "Missing type"
  end

  sig { returns(World) }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing associated world"
  end

  sig { returns(User) }
  def world_owner!
    world_owner or raise ActiveRecord::RecordNotFound, "Missing world owner"
  end

  # == Attachments

  has_rich_text :body, encrypted: true
  has_many_attached :images do |attachable|
    attachable.variant(:thumbnail, resize_to_limit: [ 800, 800 ])
  end

  # == Normalizations

  strips_text :title
  nilify_blanks :title, :emoji
  normalizes :v1_attributes, with: ->(value) { value.compact }

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
    size: { less_than: 64.megabytes },
    unless: :v1_attributes?

  # == Hooks ==

  before_validation :chomp_rich_text_body!, if: :body?
  before_save :set_plain_body
  after_save :preserve_images_attachments_ordering, if: :images_attachments_changed?
  after_create_commit :create_notifications_for_recipients!,
    if: :should_create_notifications?
  broadcasts_world_items

  # == Scopes ==

  scope :loud, -> { where(quiet: false) }
  scope :quiet, -> { where(quiet: true) }
  scope :visible_to, ->(user) {
    owned = PostType.where(world: World.where(owner: user))
    granted = PostTypeGrant
      .where("post_type_grants.world_key_id = world_keys.id")
      .where("post_type_grants.post_type_id = post_types.id")
    received = PostType.joins(:world_keys)
      .where(world_keys: { recipient: user })
      .where(granted.arel.exists)
    where(type: owned)
      .or(where(type: received))
      .where.not(":user_id = ANY(posts.hidden_from_ids)", user_id: user.id)
  }

  # scope :with_type, -> { includes(:type) }
  # scope :with_world_owner, -> { includes(:world_owner) }
  scope :with_v1_attributes, -> { where.not(v1_attributes: nil) }

  # == Notifications ==

  sig { override.params(recipient: User).returns(Notification::Message) }
  def notification_message(recipient:)
    world = world!
    Notification::Message.new(
      target_url: [ world, anchor: dom_id(self) ],
      title: world.name,
      body: snippet,
      world:,
    )
  end

  # == Recipients ==

  sig { returns(T::Array[String]) }
  def recipient_ids
    ids = type!.recipient_ids
    ids - hidden_from_ids
  end

  sig { returns(User::PrivateAssociationRelation) }
  def recipients
    type_recipients.where.not(id: hidden_from_ids)
  end

  sig { params(value: T::Array[String]).void }
  def recipient_ids=(value)
    self.hidden_from_ids = type_recipient_ids - value
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

  # == Images ==

  sig { returns(T::Array[ActiveStorage::Attachment]) }
  def ordered_images_attachments
    if new_record?
      images.attachments.to_a
    else
      images.attachments
        .index_by(&:id)
        .values_at(*T.unsafe(ordered_images_attachment_ids))
        .compact
    end
  end

  sig { returns(T::Array[T.any(ActiveStorage::VariantWithRecord, ActiveStorage::Blob)]) }
  def ordered_images_thumbnails
    ordered_images_attachments.map do |attachment|
      blob = attachment.blob or next
      if blob.content_type == "image/gif"
        blob
      else
        attachment.variant(:thumbnail)
      end
    end
  end

  sig { returns(T::Array[ActiveStorage::Blob]) }
  def ordered_images_blobs
    ordered_images_attachments.filter_map(&:blob)
  end

  # == Visibility ==

  sig { params(user: User).returns(T::Boolean) }
  def visible_to?(user)
    !!(user == world_owner! ||
      (recipients.include?(user) && hidden_from_ids.exclude?(user.id)))
  end

  # == Methods ==

  sig { params(query: String).returns(T::Enumerator[Post]) }
  def self.search_each(query)
    pattern = /\b#{Regexp.escape(query)}/
    Enumerator.new do |yielder|
      find_each do |post|
        yielder << post if pattern.match?(post.content)
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def should_create_notifications?
    !v1_attributes? && loud?
  end

  sig { returns(T::Boolean) }
  def previously_latest_post?
    world = world!
    if (latest_post_created_at = world.posts.maximum(:created_at))
      if destroyed?
        created_at > latest_post_created_at
      else
        created_at == latest_post_created_at
      end
    else
      true
    end
  end

  sig { returns(T::Boolean) }
  def images_attachments_changed?
    attachment_changes.include?("images")
  end

  # == Callbacks ==

  sig { void }
  def chomp_rich_text_body!
    document = body.body.fragment.source
    document.children.reverse_each do |node|
      if node.text.strip.blank?
        node.remove
      else
        break
      end
    end
    self.body = document.to_html
  end

  sig { void }
  def set_plain_body
    self.plain_body = rich_text_body.to_plain_text.gsub("\n\n", "\n")
  end

  sig { void }
  def preserve_images_attachments_ordering
    update_column("ordered_images_attachment_ids", images_attachments.map(&:id)) # rubocop:disable Rails/SkipsModelValidations
  end

  # sig { void }
  # def touch_world_cards
  #   world_cards.active.find_each(&:touch)
  # end

  sig { void }
  def create_notifications_for_recipients!
    recipients.find_each do |subscriber|
      notifications.create!(
        recipient: subscriber,
        delivery_delay: NOTIFICATION_DELIVERY_DELAY,
      )
    end
  end
end
