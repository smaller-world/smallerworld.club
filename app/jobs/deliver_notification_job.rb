# typed: strict
# frozen_string_literal: true

class DeliverNotificationJob < ApplicationJob
  # == Configuration ==

  limits_concurrency key: ->(notification) { notification }, on_conflict: :discard

  # == Job ==

  sig { params(notification: Notification).void }
  def perform(notification)
    notification.deliver
  end
end
