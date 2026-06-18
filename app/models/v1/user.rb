# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id                              :uuid             not null, primary key
#  allow_space_replies             :boolean          default(TRUE), not null
#  deprecated_allow_friend_sharing :boolean
#  deprecated_handle               :string
#  deprecated_hide_neko            :boolean
#  deprecated_hide_stats           :boolean
#  deprecated_reply_to_number      :string
#  deprecated_theme                :string
#  membership_tier                 :string
#  name                            :string           not null
#  notifications_last_cleared_at   :timestamptz
#  phone_number                    :string           not null
#  time_zone_name                  :string           not null
#  created_at                      :timestamptz      not null
#  updated_at                      :timestamptz      not null
#
# Indexes
#
#  index_users_on_deprecated_handle              (deprecated_handle) UNIQUE
#  index_users_on_membership_tier                (membership_tier)
#  index_users_on_notifications_last_cleared_at  (notifications_last_cleared_at)
#  index_users_on_phone_number                   (phone_number) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
module V1
  class User < ApplicationRecord
    include NormalizesPhoneNumber

    # == Configuration ==

    self.table_name = "users"

    # == Associations ==

    has_many :posts,
      class_name: "V1::Post",
      foreign_key: :author_id,
      inverse_of: :author,
      dependent: :destroy

    # == Normalizations ==

    normalizes_phone_number :phone_number

    # == Finders ==

    sig { params(phone_number: String).returns(T.nilable(V1::User)) }
    def self.find_by_phone_number(phone_number)
      phone_number = normalize_value_for(:phone_number, phone_number)
      find_by(phone_number:)
    end
  end
end
