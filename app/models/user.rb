# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id                            :uuid             not null, primary key
#  name                          :string           not null
#  notifications_last_cleared_at :timestamptz
#  phone_number                  :string           not null
#  time_zone_name                :string           not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_users_on_phone_number  (phone_number) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class User < ApplicationRecord
  include NormalizesPhoneNumber
  include HasTimeZone

  # == Constants ==

  NAME_MAX_LENGTH = 22

  # Attributes that, when changed, invalidate the on-device pass for each world
  # card.
  WORLD_CARD_ATTRIBUTES = T.let([ "name" ].freeze, T::Array[String])

  # == Attributes ==

  sig { returns(Phonelib::Phone) }
  def parsed_phone_number
    Phonelib.parse(phone_number)
  end

  sig { returns(String) }
  def interpreted_first_name
    name.split(" ").first || name
  end

  # == Associations ==

  has_many :sessions, dependent: :destroy
  has_many :owned_worlds,
    class_name: "World",
    inverse_of: :owner,
    foreign_key: :owner_id,
    dependent: :destroy
  has_many :posts, through: :worlds
  has_many :reactions,
    inverse_of: :reactor,
    foreign_key: :reactor_id,
    dependent: :destroy
  has_many :reply_initiations,
    inverse_of: :replier,
    foreign_key: :replier_id,
    dependent: :destroy
  has_many :devices,
    inverse_of: :owner,
    foreign_key: :owner_id,
    dependent: :destroy
  has_many :world_cards,
    inverse_of: :cardholder,
    foreign_key: :cardholder_id,
    dependent: :destroy
  has_many :received_notifications,
    class_name: "Notification",
    inverse_of: :recipient,
    foreign_key: :recipient_id,
    dependent: :destroy

  has_many :world_keys,
    dependent: :destroy,
    inverse_of: :recipient,
    foreign_key: :recipient_id
  has_many :accessible_worlds,
    -> { distinct },
    class_name: "World",
    through: :world_keys,
    source: :world

  # == Normalizations ==

  normalizes_phone_number :phone_number

  # == Validations ==

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }
  validates :phone_number,
    presence: true,
    uniqueness: { message: "already registered" },
    phone: { possible: true, types: :mobile, extensions: false }
  validates_time_zone_name

  # == Hooks ==

  after_update_commit :touch_world_cards, if: :saved_changes_to_world_card_attributes?

  # == Notifications ==

  sig do
    returns(T.any(
      Notification::PrivateAssociationRelation,
      Notification::PrivateCollectionProxy,
    ))
  end
  def notifications_received_since_last_cleared
    if (last_cleared_at = notifications_last_cleared_at)
      received_notifications.where("created_at > ?", last_cleared_at)
    else
      received_notifications
    end
  end

  # == Methods ==

  sig { returns(String) }
  def default_world_name
    "#{interpreted_first_name}'s world"
  end

  sig { params(platform: Symbol, message: String, native: T::Boolean).returns(String) }
  def dm_url(platform:, message:, native: false)
    escaped_message = CGI.escapeURIComponent(message)
    case platform
    when :sms
      "sms:#{phone_number}?body=#{escaped_message}"
    when :whatsapp
      "https://wa.me/#{phone_number}?text=#{escaped_message}"
    when :telegram
      if native
        "tg://msg?to=#{phone_number}&text=#{escaped_message}"
      else
        "https://t.me/#{phone_number}?text=#{escaped_message}"
      end
    else
      raise ArgumentError, "Unsupported platform: #{platform.inspect}"
    end
  end

  sig do
    params(pass_serial_numbers: T::Array[String])
      .returns(WorldCard::PrivateRelation)
  end
  def world_cards_pending_key_creation(pass_serial_numbers:)
    matching_key = WorldKey
      .where("world_keys.world_id = world_cards.world_id")
      .where("world_keys.color = world_cards.granted_key_color")
      .where(recipient_id: id)
    WorldCard.where(
      id: WorldCard.ids_pending_key_creation(pass_serial_numbers:)
        .where.not(matching_key.arel.exists),
    )
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def saved_changes_to_world_card_attributes?
    saved_changes.keys.intersect?(WORLD_CARD_ATTRIBUTES)
  end

  # == Callbacks ==

  sig { void }
  def touch_world_cards
    world_cards.find_each(&:touch)
  end
end
