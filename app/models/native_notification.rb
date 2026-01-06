# typed: true
# frozen_string_literal: true


class NativeNotification < ActionPushNative::Notification
  extend T::Sig

  # Set a custom job queue_name
  # queue_as :realtime

  # Controls whether push notifications are enabled (default: !Rails.env.test?)
  # self.enabled = Rails.env.production?

  # == Callbacks ==

  # Define a custom callback to modify or abort the notification before it is
  # sent
  # before_delivery do |notification|
  #   throw :abort if Notification.find(notification.context[:notification_id])
  #     .expired?
  # end
end
