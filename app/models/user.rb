# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id                  :uuid             not null, primary key
#  app_last_visited_at :timestamptz
#  has_v1_account      :boolean          default(FALSE), not null
#  name                :string           not null
#  phone_number        :string           not null
#  time_zone_name      :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_users_on_phone_number  (phone_number) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class User < ApplicationRecord
  extend FriendlyId
  include NormalizesPhoneNumber
  include HasTimeZone
  include PgSearch::Model

  # == Constants ==

  NAME_MAX_LENGTH = 22

  # Attributes that, when changed, invalidate the on-device pass for each world
  # card.
  WORLD_CARD_ATTRIBUTES = T.let([ "name" ].freeze, T::Array[String])

  # == FriendlyId ==

  friendly_id :phone_number, use: :slugged, slug_column: :phone_number

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
  has_many :posts, through: :owned_worlds
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

  # has_many :world_cards,
  #   inverse_of: :cardholder,
  #   foreign_key: :cardholder_id,
  #   dependent: :destroy

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
    through: :world_keys,
    source: :world
  has_many :accessible_world_owners,
    -> { distinct },
    through: :world_keys,
    source: :world_owner

  sig { returns(WorldInvitation::PrivateRelation) }
  def world_invitations
    WorldInvitation.where(recipient_id: id)
      .or(WorldInvitation.where(recipient_phone_number: phone_number))
  end

  sig { returns(T.nilable(String)) }
  def primary_world_id
    owned_worlds.chronological.pick(:id)
  end

  sig { params(world: World).returns(User::PrivateAssociationRelation) }
  def accessible_world_owners_without_key_for(world)
    accessible_world_owners.where.not(id: world.keys.select(:recipient_id))
  end

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

  before_create :set_has_v1_account unless Rails.env.test?

  # == Search ==

  pg_search_scope :search,
    against: [ :name ],
    using: {
      tsearch: {
        websearch: true,
      },
    }

  # == Notifications ==

  sig do
    returns(T.any(
      Notification::PrivateAssociationRelation,
      Notification::PrivateCollectionProxy,
    ))
  end
  def notifications_received_since_app_last_visited
    if (visited_at = app_last_visited_at)
      received_notifications.where("created_at > ?", visited_at)
    else
      received_notifications
    end
  end

  sig { returns(T::Boolean) }
  def has_pending_notifications?
    notifications_received_since_app_last_visited.any?
  end

  # sig { void }
  # def send_badge_count_notifications
  #   notification = DevicePushNotification.new(
  #     badge: notifications_received_since_app_last_visited.count,
  #     high_priority: false,
  #   )
  #   devices.find_each do |device|
  #     device.push(notification)
  #   end
  # end

  # sig { returns(T.any(SendUserBadgeCountNotificationsJob, FalseClass)) }
  # def send_badge_count_notifications_later
  #   SendUserBadgeCountNotificationsJob.perform_later(self)
  # end

  # == Methods ==

  sig { params(phone_number: String).returns(T.nilable(User)) }
  def self.find_by_phone_number(phone_number)
    phone_number = User.normalize_value_for(:phone_number, phone_number)
    find_by(phone_number:)
  end

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

  sig { returns(T::Boolean) }
  def record_app_visit
    update(app_last_visited_at: Time.current)
  end

  sig { returns(T.nilable(V1::User)) }
  def v1_user
    V1::User.find_by(phone_number:)
  end

  private

  # == Callbacks ==

  sig { void }
  def set_has_v1_account
    if V1::User.exists?(phone_number:)
      self.has_v1_account = true
    end
  end

  # sig { void }
  # def touch_world_cards
  #   world_cards.find_each(&:touch)
  # end
end
