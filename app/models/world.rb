# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: worlds
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :uuid             not null
#
# Indexes
#
#  index_worlds_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class World < ApplicationRecord
  extend FriendlyId

  # == Configuration ==

  ICON_CONTENT_TYPES = [ "image/*", "video/*" ]

  # == FriendlyId ==

  # TODO: Parse this out into a module.
  module FinderMethods
    include FriendlyId::FinderMethods

    private

    def parse_friendly_id(value)
      value.split("-").last
    end
  end

  friendly_id do |config|
    config.base = :id
    config.finder_methods = FinderMethods
  end

  sig { returns(T.nilable(String)) }
  def friendly_id
    if (name = self[:name]) && (id = self[:id])
      "#{name[..32].strip.parameterize}-#{id.delete("-")}"
    end
  end

  # == Associations ==

  belongs_to :owner, class_name: "User"

  sig { returns(User) }
  def owner!
    owner or raise ActiveRecord::RecordNotFound, "Missing owner"
  end

  # == Attachments ==

  has_one_attached :icon do |attachable|
    attachable.variant(:favicon, resize_to_fill: [ 144, 144 ])
    attachable.variant(:page_icon, resize_to_fill: [ 512, 512 ])
  end

  sig { returns(T.nilable(ActiveStorage::VariantWithRecord)) }
  def favicon_variant
    icon_attachment&.variant(:favicon)
  end

  sig { returns(T.nilable(ActiveStorage::VariantWithRecord)) }
  def page_icon_variant
    icon_attachment&.variant(:page_icon)
  end

  # == Validations ==

  validates :name,
    length: { minimum: 2, maximum: 30 },
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

  # == Initialization ==

  after_initialize :set_default_name, if: :new_record?

  private

  # == Helpers ==

  sig { void }
  def set_default_name
    if (owner = self.owner)
      self[:name] ||= "#{owner.name}'s world"
    end
  end
end
