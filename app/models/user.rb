# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id               :uuid             not null, primary key
#  email_address    :string           not null
#  name             :string           not null
#  oauth_first_name :string           not null
#  oauth_last_name  :string
#  oauth_provider   :string           not null
#  oauth_uid        :string           not null
#  phone_number     :string
#  time_zone_name   :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email_address                 (email_address) UNIQUE
#  index_users_on_oauth_provider_and_oauth_uid  (oauth_provider,oauth_uid) UNIQUE
#  index_users_on_phone_number                  (phone_number)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class User < ApplicationRecord
  include NormalizesPhoneNumber
  include HasTimeZone

  # == Enumerations ==

  enumerize :oauth_provider, in: [ :apple, :google ]

  # == Attachments ==

  has_one_attached :oauth_picture

  # == Normalizations ==

  normalizes :email_address, with: ->(address) { address.strip.downcase }
  normalizes_phone_number :phone_number

  # == Validations ==

  validates :oauth_provider, :oauth_uid, presence: true
  validates :oauth_first_name, presence: true
  validates :oauth_last_name, length: { maximum: 30 }, allow_nil: true
  validates :name, presence: true, length: { maximum: 30 }
  validates :email_address, presence: true, email: true
  validates :phone_number,
            phone: { possible: true, types: :mobile, extensions: false },
            allow_nil: true
  validates_time_zone_name

  # == Associations ==

  has_many :sessions, dependent: :destroy

  # == Class methods ==

  sig do
    params(
      provider: Symbol,
      uid: String,
      first_name: T.nilable(String),
      last_name: T.nilable(String),
      picture_url: T.nilable(String),
      attributes: T.untyped,
    ).returns(User)
  end
  def self.from_oauth_provider!(
    provider,
    uid:,
    first_name: nil,
    last_name: nil,
    picture_url: nil,
    **attributes
  )
    email_address = attributes[:email_address]&.strip&.downcase
    if email_address.present? &&
        (existing = find_by(email_address: email_address)) &&
        existing.oauth_provider != provider.to_s
      raise "An account with this email already exists. Please sign in with " \
        "#{existing.oauth_provider.titleize}."
    end

    user = find_or_initialize_by(oauth_provider: provider, oauth_uid: uid) do |user|
      raise "Missing first name" unless first_name

      user.oauth_first_name = first_name
      user.oauth_last_name = last_name
      user.name = first_name.truncate(30)
      if picture_url.present?
        picture = Down.download(picture_url)
        user.oauth_picture.attach(
          io: picture,
          filename: picture.original_filename,
          content_type: picture.content_type,
        )
      end
    end
    user.update!(**attributes)
    user
  end
end
