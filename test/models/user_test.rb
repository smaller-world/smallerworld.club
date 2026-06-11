# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id                            :uuid             not null, primary key
#  name                          :string           not null
#  notifications_last_cleared_at :timestamptz
#  phone_number                  :string           not null
#  time_zone_name                :string           not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_users_on_phone_number  (phone_number) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:bob) # phone_number +14165558323
  end

  test "dm_url builds an sms link" do
    url = @user.dm_url(platform: :sms, message: "hi there")

    assert_equal "sms:#{@user.phone_number}?body=hi%20there", url
  end

  test "dm_url builds a whatsapp link" do
    url = @user.dm_url(platform: :whatsapp, message: "hi there")

    assert_equal "https://wa.me/#{@user.phone_number}?text=hi%20there", url
  end

  test "dm_url builds a telegram link" do
    url = @user.dm_url(platform: :telegram, message: "hi there")

    assert_equal "https://t.me/#{@user.phone_number}?text=hi%20there", url
  end
end
