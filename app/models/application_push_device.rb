# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: action_push_native_devices
#
#  id         :bigint           not null, primary key
#  name       :string
#  owner_type :string
#  platform   :string           not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :bigint
#
# Indexes
#
#  index_action_push_native_devices_on_owner  (owner_type,owner_id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class ApplicationPushDevice < ActionPushNative::Device
  # Customize TokenError handling (default: destroy!)
  # rescue_from (ActionPushNative::TokenError) { Rails.logger.error("Device #{id} token is invalid") }
end
