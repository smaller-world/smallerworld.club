# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: devices
#
#  id         :uuid             not null, primary key
#  identifier :string           not null
#  name       :string
#  platform   :string           not null
#  push_token :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :uuid
#
# Indexes
#
#  index_devices_on_identifier  (identifier) UNIQUE
#  index_devices_on_owner_id    (owner_id)
#  index_devices_on_push_token  (push_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  setup do
    @previous = devices(:sues_tablet)
    @previous.update!(push_token: "apns-token")
  end

  test "adopting a push token supersedes the device that held it" do
    device = devices(:sues_phone)

    assert device.update(push_token: "apns-token")
    assert_empty device.errors
    assert_not Device.exists?(@previous.id)
  end

  test "a failed save leaves the device that held the push token intact" do
    device = devices(:sues_phone)
    device[:identifier] = nil

    assert_not device.update(push_token: "apns-token")
    assert Device.exists?(@previous.id)
  end
end
