# typed: strict
# frozen_string_literal: true

Rails.application.configure do
  config.to_prepare do
    ActionPushNative::Device.table_name = "devices"
  end
end
