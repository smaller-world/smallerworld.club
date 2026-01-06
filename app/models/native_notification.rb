# typed: true
# frozen_string_literal: true


class NativeNotification < ActionPushNative::Notification
  extend T::Sig

  # Set a custom job queue_name
  # queue_as :realtime

  # Controls whether push notifications are enabled (default: !Rails.env.test?)
  # self.enabled = Rails.env.production?

  # Define a custom callback to modify or abort the notification before it is
  # sent
  # before_delivery do |notification|
  #   throw :abort if Notification.find(notification.context[:notification_id])
  #     .expired?
  # end

  # == Methods ==
  sig do
    override
      .params(devices: T.any(NativeDevice, T::Enumerable[NativeDevice]))
      .void
  end
  def deliver_later_to(devices)
    Array(devices).each do |device|
      NativeNotificationJob
        .set(queue: queue_name)
        .perform_later(self.class.name, self.as_json, device)
    end
  end
end
