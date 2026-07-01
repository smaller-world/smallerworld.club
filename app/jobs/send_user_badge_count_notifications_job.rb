# typed: strict
# frozen_string_literal: true

class SendUserBadgeCountNotificationsJob < ApplicationJob
  # == Configuration ==

  # Only one import job may run per world at a time.
  limits_concurrency key: ->(user) { user }, on_conflict: :discard

  # == Job ==

  sig { params(user: User).void }
  def perform(user)
    user.send_badge_count_notifications
  end
end
