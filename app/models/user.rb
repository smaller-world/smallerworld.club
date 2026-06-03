# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id             :uuid             not null, primary key
#  name           :string           not null
#  phone_number   :string           not null
#  time_zone_name :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
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
    dependent: :destroy,
    inverse_of: :owner,
    foreign_key: :owner_id
  has_many :posts, through: :worlds
  has_many :world_keys,
    dependent: :destroy,
    inverse_of: :recipient,
    foreign_key: :recipient_id
  has_many :accessible_worlds,
    -> { distinct },
    class_name: "World",
    through: :world_keys,
    source: :world
  has_many :reactions,
    dependent: :destroy,
    inverse_of: :reactor,
    foreign_key: :reactor_id
  has_many :reply_initiations,
    dependent: :destroy,
    inverse_of: :replier,
    foreign_key: :replier_id
  has_many :devices, dependent: :destroy, inverse_of: :owner, foreign_key: :owner_id

  # TODO: Touch cards when user name or details changes.
  has_many :world_cards,
    dependent: :destroy,
    inverse_of: :cardholder,
    foreign_key: :cardholder_id
  has_many :world_card_passes,
    through: :world_cards,
    source: :pass

  # == Normalizations ==

  normalizes_phone_number :phone_number

  # == Validations ==

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }
  validates :phone_number,
    presence: true,
    uniqueness: { message: "already registered" },
    phone: { possible: true, types: :mobile, extensions: false }
  validates_time_zone_name

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
end
