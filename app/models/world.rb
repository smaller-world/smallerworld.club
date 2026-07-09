# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: worlds
#
#  id                               :uuid             not null, primary key
#  blurb                            :text
#  last_imported_v1_post_created_at :timestamptz
#  name                             :string           not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  owner_id                         :uuid             not null
#
# Indexes
#
#  index_worlds_on_name_and_owner_id  (name,owner_id) UNIQUE
#  index_worlds_on_owner_id           (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class World < ApplicationRecord
  extend FriendlyId
  include NormalizesText
  include PgSearch::Model

  include V1Importing

  # == Configuration ==

  NAME_MAX_LENGTH = 30
  ICON_CONTENT_TYPES = [ "image/*", "video/*" ]

  # Attributes that, when changed, invalidate the on-device pass for each card.
  # Icon changes are handled separately via `after_attached :icon`.
  CARD_ATTRIBUTES = T.let([ "name" ].freeze, T::Array[String])

  # == FriendlyId ==

  friendly_id :name, use: FriendlyId::DynamicSlugged

  # == Associations ==

  belongs_to :owner, class_name: "User"
  has_many :post_types, dependent: :destroy
  has_many :posts, through: :post_types
  # has_many :cards, class_name: "WorldCard", dependent: :destroy

  has_many :keys, class_name: "WorldKey", dependent: :destroy
  has_many :key_recipients, -> { distinct }, through: :keys, source: :recipient

  has_many :invitations, class_name: "WorldInvitation", dependent: :destroy

  sig { returns(User) }
  def owner!
    owner or raise ActiveRecord::RecordNotFound, "Missing owner"
  end

  # == Attachments ==

  has_one_attached :icon do |attachable|
    attachable.variant(:page_icon, resize_to_fill: [ 255, 256 ])
    attachable.variant(:notification_icon, resize_to_fill: [ 192, 192 ], format: :png)

    attachable.variant(
      :passkit_logo,
      passkit_world_icon: [ 50 ],
      format: :png,
    )
    attachable.variant(
      :passkit_logo_2x,
      passkit_world_icon: [ 100 ],
      format: :png,
    )
    attachable.variant(
      :passkit_icon,
      passkit_world_icon: [ 29 ],
      format: :png,
    )
    attachable.variant(
      :passkit_icon_2x,
      passkit_world_icon: [ 58 ],
      format: :png,
    )
    attachable.variant(
      :passkit_icon_3x,
      passkit_world_icon: [ 87 ],
      format: :png,
    )
  end

  sig { returns(ActiveStorage::Attachment) }
  def icon_attachment!
    icon_attachment or raise ActiveRecord::RecordNotFound, "Missing icon attachment"
  end

  sig { returns(T.any(ActiveStorage::VariantWithRecord, ActiveStorage::Blob)) }
  def page_icon_variant
    attachment = icon_attachment!
    blob = T.must(attachment.blob)
    if blob.content_type == "image/gif"
      blob
    else
      attachment.variant(:page_icon)
    end
  end

  sig { returns(ActiveStorage::VariantWithRecord) }
  def notification_icon_variant
    attachment = icon_attachment!
    attachment.variant(:notification_icon)
  end

  # == Normalizations ==

  strips_text :name, :blurb
  nilify_blanks :blurb

  # == Validations ==

  validates :name,
    presence: true,
    length: { maximum: NAME_MAX_LENGTH },
    uniqueness: {
      scope: :owner_id,
      message: ->(_object, data) {
        value = data.fetch(:value)
        %{you have another world named "#{value}"}
      },
    }
  validates :icon,
    attached: true,
    processable_file: true,
    content_type: {
      with: %r{\A(image|video)/[a-z]+\z},
      spoofing_protection: true,
    },
    size: { less_than: 64.megabytes }

  # == Hooks ==

  after_initialize :set_default_name, if: :new_record?
  after_initialize :set_default_post_types, if: :new_record?

  # == Search ==

  pg_search_scope :search,
    against: [ :name ],
    using: {
      tsearch: {
        websearch: true,
      },
    }

  # == Scopes ==

  scope :order_by_latest_post_visible_to, ->(user) {
    latest_post_at = Arel::Nodes::Grouping.new(
      Post.visible_to(user)
        .joins(:type)
        .where(PostType.arel_table[:world_id].eq(arel_table[:id]))
        .select(Post.arel_table[:created_at].maximum)
        .arel,
    )
    select(arel_table[Arel.star], latest_post_at.as("latest_post_at"))
      .order(latest_post_at.desc.nulls_last)
  }

  # == Post Types ==

  sig { returns(T::Array[PostType]) }
  def self.default_post_types
    [
      PostType.new(label: "journal entry", icon: "huge/book-edit"),
      PostType.new(label: "poem", icon: "huge/quill-write-01"),
      PostType.new(label: "invitation", icon: "huge/mail-open-love"),
      PostType.new(label: "ask", icon: "huge/waving-hand-02"),
    ]
  end

  # == Keys ==

  sig { params(post_type_ids: T::Array[String]).returns(String) }
  def key_grant_message(post_type_ids: [])
    WorldKey.grant_verifier.generate({ world_id: id, post_type_ids: })
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def owner_phone_number
    if association_cached?(:owner)
      owner!.phone_number
    else
      User.where(id: owner_id).pick(:phone_number)
    end
  end

  # == Callbacks ==

  sig { void }
  def set_default_name
    if (owner = self.owner)
      self[:name] ||= owner.default_world_name
    end
  end

  sig { void }
  def set_default_post_types
    self.post_types = self.class.default_post_types
  end
end
