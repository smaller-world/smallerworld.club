# typed: true
# frozen_string_literal: true

require "test_helper"

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
class UserTest < ActiveSupport::TestCase
  extend T::Sig

  # == Tests ==

  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")

    assert_equal("downcased@example.com", user.email_address)
  end
end
