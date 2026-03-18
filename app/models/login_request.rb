# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: login_requests
#
#  id           :uuid             not null, primary key
#  completed_at :datetime
#  ip_address   :inet
#  login_code   :string           not null
#  phone_number :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_login_requests_on_completed_at               (completed_at)
#  index_login_requests_on_created_at_and_ip_address  (created_at,ip_address)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class LoginRequest < ApplicationRecord
  include NormalizesPhoneNumber

  # == Constants ==

  EXPIRATION_DURATION = 5.minutes
  DAILY_RATE_LIMIT = 7

  # == Attributes ==

  attribute :login_code, default: -> { generate_login_code }

  sig { returns(T::Boolean) }
  def completed? = completed_at?

  # == Tokens ==

  generates_token_for :registration

  sig { params(token: String).returns(LoginRequest) }
  def self.find_by_registration_token!(token)
    find_by_token_for!(:registration, token)
  end

  sig { params(token: String).returns(T.nilable(LoginRequest)) }
  def self.find_by_registration_token(token)
    find_by_token_for(:registration, token)
  end

  sig { returns(String) }
  def generate_registration_token
    generate_token_for(:registration)
  end


  # == Normalizations ==

  normalizes_phone_number :phone_number

  # == Validations ==

  validates :phone_number,
            presence: true,
            phone: { possible: true, types: :mobile, extensions: false }
  validates :ip_address,
            presence: true,
            exclusion: {
              in: ->(request) { ip_addresses_exceeding_daily_rate_limit },
              message: "is blacklisted",
            }

  # == Callbacks ==

  before_create :deliver_login_code, if: :should_deliver_login_code?

  # == Scopes ==

  scope :incomplete, -> { where(completed_at: nil) }

  # == Methods ==

  sig { returns(T.nilable(String)) }
  def verified_phone_number
    phone_number if completed?
  end

  sig { returns(String) }
  def login_code_message
    "your smaller world login code is: #{login_code}"
  end

  sig { returns(T::Boolean) }
  def expired?
    created_at < EXPIRATION_DURATION.ago
  end

  sig { params(login_code: String).returns(T::Boolean) }
  def authenticate(login_code)
    if completed? || expired?
      errors.add(:login_code, :invalid, message: "is no longer valid")
      return false
    end

    if login_code != self.login_code
      errors.add(:login_code, :invalid, message: "bad code")
      return false
    end

    update(completed_at: Time.current)
  end

  sig { void }
  def deliver_login_code
    TwilioService.send_message(to: phone_number, body: login_code_message)
  end

  sig { returns(T::Boolean) }
  def should_deliver_login_code?
    Rails.env.production?
  end

  sig { returns(Phonelib::Phone) }
  def phone
    Phonelib.parse(phone_number)
  end

  sig { returns(T::Enumerable[IPAddr]) }
  def self.ip_addresses_exceeding_daily_rate_limit
    where(created_at: (1.day.ago)..)
      .where.not(ip_address: nil)
      .group(:ip_address)
      .having("COUNT(*) >= ?", DAILY_RATE_LIMIT)
      .pluck(:ip_address)
  end

  # == Helpers ==

  sig { returns(String) }
  def self.generate_login_code
    format("%06d", rand(0..999_999))
  end
end
