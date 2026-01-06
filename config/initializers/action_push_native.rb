# typed: true
# frozen_string_literal: true

Rails.application.config.after_initialize do
  ActionPushNative::Notification::ApplicationPushNotificationJob =
    DeliverNativeNotificationJob
end
