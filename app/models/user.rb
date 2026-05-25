# typed: true
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

  MESSAGING_PLATFORMS = [ :sms, :whatsapp, :telegram ].freeze

  # == Attributes ==

  sig { returns(Phonelib::Phone) }
  def parsed_phone_number
    Phonelib.parse(phone_number)
  end

  # == Associations ==

  has_many :sessions, dependent: :destroy
  has_one :own_world,
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

  sig { returns(World) }
  def own_world!
    own_world or raise ActiveRecord::RecordNotFound, "Missing world"
  end

  # == Normalizations ==

  normalizes_phone_number :phone_number

  # == Validations ==

  validates :name, presence: true, length: { maximum: 30 }
  validates :phone_number,
    presence: true,
    uniqueness: { message: "already registered" },
    phone: { possible: true, types: :mobile, extensions: false }
  validates_time_zone_name

  # == Methods ==

  sig { returns(String) }
  def default_world_name
    "#{name}'s world"
  end

  sig { params(platform: Symbol, message: String).returns(String) }
  def dm_url(platform:, message:)
    escaped_message = CGI.escapeURIComponent(message)
    case platform
    when :sms
      "sms:#{phone_number}?body=#{escaped_message}"
    when :whatsapp
      "https://wa.me/#{phone_number}?text=#{escaped_message}"
    when :telegram
      "https://t.me/#{phone_number}?text=#{escaped_message}"
    else
      raise ArgumentError, "Unsupported platform: #{platform.inspect}"
    end
  end
end
