# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id               :uuid             not null, primary key
#  apple_first_name :string           not null
#  apple_last_name  :string           not null
#  apple_uid        :string           not null
#  email_address    :string           not null
#  name             :string           not null
#  phone_number     :string
#  time_zone_name   :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_apple_uid      (apple_uid) UNIQUE
#  index_users_on_email_address  (email_address) UNIQUE
#  index_users_on_phone_number   (phone_number)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class User < ApplicationRecord
  include NormalizesPhoneNumber
  include HasTimeZone

  # == Normalizations ==

  normalizes :email_address, with: ->(address) { address.strip.downcase }
  normalizes_phone_number :phone_number

  # == Validations ==

  validates :apple_first_name, :apple_last_name, presence: true
  validates :name, presence: true, length: { maximum: 30 }
  validates :email_address, presence: true, email: true
  validates :phone_number,
            phone: { possible: true, types: :mobile, extensions: false },
            allow_nil: true
  validates_time_zone_name

  # == Associations ==

  has_many :sessions, dependent: :destroy
end
