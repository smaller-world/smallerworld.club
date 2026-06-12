# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: worlds
#
#  id         :uuid             not null, primary key
#  blurb      :text
#  key_labels :jsonb
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :uuid             not null
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

  # == Configuration ==

  NAME_MAX_LENGTH = 30
  ICON_CONTENT_TYPES = [ "image/*", "video/*" ]

  # Attributes that, when changed, invalidate the on-device pass for each card.
  # Icon changes are handled separately via `after_attached :icon`.
  CARD_ATTRIBUTES = T.let([ "name" ].freeze, T::Array[String])

  # == FriendlyId ==

  friendly_id :name, use: FriendlyId::DynamicSlugged

  # == Attributes ==

  typed_store(
    :key_labels,
    suffix: :key_label,
    coder: ActiveRecord::TypedStore::IdentityCoder,
  ) do |s|
    WorldKey.color.values.each do |color|
      s.string(color.to_s, blank: false)
    end
  end

  # == Associations ==

  belongs_to :owner, class_name: "User"
  has_many :posts, dependent: :destroy
  has_many :keys, class_name: "WorldKey", dependent: :destroy
  has_many :key_recipients, -> { distinct }, through: :keys, source: :recipient
  has_many :cards, class_name: "WorldCard", dependent: :destroy

  sig { returns(User) }
  def owner!
    owner or raise ActiveRecord::RecordNotFound, "Missing owner"
  end

  # == Attachments ==

  has_one_attached :icon do |attachable|
    # attachable.variant(:favicon, resize_to_fill: [ 144, 144 ])
    attachable.variant(:page_icon, resize_to_fill: [ 255, 256 ])
    attachable.variant(:notification_icon, resize_to_fill: [ 192, 192 ])

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

  # sig { returns(T.nilable(ActiveStorage::VariantWithRecord)) }
  # def favicon_variant
  #   icon_attachment&.variant(:favicon)
  # end

  sig { returns(T.nilable(T.any(ActiveStorage::VariantWithRecord, ActiveStorage::Blob))) }
  def page_icon_variant
    attachment = icon_attachment or return
    blob = attachment.blob or return
    if blob.content_type == "image/gif"
      blob
    else
      attachment.variant(:page_icon)
    end
  end

  sig { returns(T.nilable(ActiveStorage::VariantWithRecord)) }
  def notification_icon_variant
    icon_attachment&.variant(:notification_icon)
  end

  # == Normalizations ==

  strips_text :name, :blurb
  nilify_blanks :blurb
  normalizes :key_labels, with: ->(value) {
    value.transform_values { |value| value&.strip }.compact_blank
  }

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
  after_update_commit :touch_cards, if: :saved_changes_to_card_attributes?
  after_attached :icon, :touch_cards

  # == Search ==

  pg_search_scope :search,
    against: [ :name ],
    using: {
      tsearch: {
        websearch: true,
      },
    }

  # == Keys ==

  sig { params(color: T.any(Symbol, String, Enumerize::Value)).returns(String) }
  def key_grant(color:)
    id = self[:id] or raise "Missing world ID"
    WorldKey.grant_verifier.generate({ world_id: id, color: color.to_s })
  end

  sig { params(color: T.any(Symbol, Enumerize::Value)).returns(String) }
  def key_label(color:)
    color = color.to_s
    descriptor = key_labels[color] || color.humanize(capitalize: false)
    "#{descriptor} key"
  end

  private

  # == Helpers ==

  sig { void }
  def set_default_name
    if (owner = self.owner)
      self[:name] ||= owner.default_world_name
    end
  end

  sig { returns(T::Boolean) }
  def saved_changes_to_card_attributes?
    saved_changes.keys.intersect?(CARD_ATTRIBUTES)
  end

  # == Callbacks ==

  sig { params(args: T.untyped).void }
  def touch_cards(*args)
    cards.find_each(&:touch)
  end
end
