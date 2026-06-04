# typed: strict
# frozen_string_literal: true

class PushNotification < ActionPushNative::Notification
  # == Configuration ==

  ApplicationPushNotificationJob = PushNotificationJob

  # The action_push_native `application:` config block is special-cased as
  # the shared base for every notification class. Pointing PushNotification
  # at it means main-app pushes read their topic directly from that block,
  # so we don't need a separate per-app block just for the defaults.
  self.application = "application"

  # Set a custom job queue_name
  # queue_as :realtime

  # Controls whether push notifications are enabled (default: !Rails.env.test?)
  # self.enabled = Rails.env.production?

  # Define a custom callback to modify or abort the notification before it is sent
  # before_delivery do |notification|
  #   throw :abort if Notification.find(notification.context[:notification_id]).expired?
  # end
end
