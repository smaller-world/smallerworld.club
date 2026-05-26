# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: phone_number_verification_requests
#
#  id                :uuid             not null, primary key
#  ip_address        :inet             not null
#  phone_number      :string           not null
#  user_agent        :string           not null
#  verification_code :string           not null
#  verified_at       :timestamptz
#  created_at        :timestamptz      not null
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class PhoneNumberVerificationRequest < ApplicationRecord
  include NormalizesPhoneNumber

  # == Configuration ==

  EXPIRATION_DURATION = T.let(5.minutes, ActiveSupport::Duration)
  DAILY_RATE_LIMIT = 7

  # == Attributes ==

  attribute :verification_code, default: -> { generate_verification_code }

  sig { returns(T::Boolean) }
  def verified? = verified_at?

  sig { returns(T::Boolean) }
  def expired?
    created_at < EXPIRATION_DURATION.ago
  end

  sig { returns(T.nilable(String)) }
  def verified_phone_number
    phone_number if verified?
  end

  # == Normalizations ==

  normalizes_phone_number :phone_number

  # == Validations ==

  validates :ip_address,
    presence: true,
    exclusion: {
      in: ->(_request) { ip_addresses_exceeding_daily_rate_limit },
      message: "is temporarily blacklisted",
    } if Rails.env.production?
  validates :phone_number,
    presence: true,
    phone: { possible: true, types: :mobile, extensions: false, allow_blank: true }

  # == Scopes ==

  scope :pending_verification, -> {
    where(validated_at: nil)
      .where("created_at > ", EXPIRATION_DURATION.ago)
  }

  # == Tokens ==

  generates_token_for :registration

  sig { params(token: String).returns(PhoneNumberVerificationRequest) }
  def self.find_by_registration_token!(token)
    find_by_token_for!(:registration, token)
  end

  sig { params(token: String).returns(T.nilable(PhoneNumberVerificationRequest)) }
  def self.find_by_registration_token(token)
    find_by_token_for(:registration, token)
  end

  sig { returns(String) }
  def generate_registration_token
    raise "Phone number not verified" unless verified?

    generate_token_for(:registration)
  end

  # == Methods ==

  sig { returns(T::Enumerable[IPAddr]) }
  def self.ip_addresses_exceeding_daily_rate_limit
    where(created_at: (1.day.ago)..)
      .where.not(ip_address: nil)
      .group(:ip_address)
      .having("COUNT(*) >= ?", DAILY_RATE_LIMIT)
      .pluck(:ip_address)
  end

  sig { returns(String) }
  def self.generate_verification_code
    format("%06d", rand(0..999_999))
  end

  sig { returns(Phonelib::Phone) }
  def parsed_phone_number
    Phonelib.parse(phone_number)
  end

  sig { returns(String) }
  def verification_code_message
    "your smaller world verification code is: #{verification_code}"
  end

  sig { void }
  def deliver_verification_code
    raise NotImplementedError
    # TwilioService.send_message(to: phone_number, body: login_code_message)
  end

  sig { returns(T::Boolean) }
  def should_deliver_verification_code?
    Rails.env.production?
  end

  sig { params(code: String).returns(T::Boolean) }
  def verify(code)
    if expired?
      errors.add(:verification_code, :invalid, message: "has expired")
      return false
    end

    if verified? || code != verification_code
      errors.add(:verification_code, :invalid)
      return false
    end

    update(verified_at: Time.current)
  end
end
