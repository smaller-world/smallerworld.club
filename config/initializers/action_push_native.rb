# typed: strict
# frozen_string_literal: true

# require "extensions/action_push_native/openssl3_compatibility"

Rails.application.configure do
  config.to_prepare do
    ActionPushNative::Device.table_name = "devices"
  end
end
