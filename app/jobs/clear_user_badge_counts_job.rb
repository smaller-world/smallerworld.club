# typed: strict
# frozen_string_literal: true

class ClearUserBadgeCountsJob < ApplicationJob
  # == Configuration ==

  limits_concurrency key: ->(user) { user }

  # == Job ==

  sig { params(user: User).void }
  def perform(user)
    unless user.has_pending_notifications?
      user.clear_badge_counts
    end
  end
end
