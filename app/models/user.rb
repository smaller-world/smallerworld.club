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

  # == Attributes ==

  sig { returns(Phonelib::Phone) }
  def parsed_phone_number
    Phonelib.parse(phone_number)
  end

  # == Associations ==

  has_many :sessions, dependent: :destroy
  has_many :worlds,
    dependent: :destroy,
    inverse_of: :owner,
    foreign_key: :owner_id
  has_many :posts, through: :worlds

  # == Normalizations ==

  normalizes_phone_number :phone_number

  # == Validations ==

  validates :name, presence: true, length: { maximum: 30 }
  validates :phone_number,
    uniqueness: { message: "already registered" },
    phone: { possible: true, types: :mobile, extensions: false },
    allow_nil: true
  validates_time_zone_name
end
