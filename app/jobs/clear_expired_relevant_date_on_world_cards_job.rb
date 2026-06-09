# typed: strict
# frozen_string_literal: true

class ClearExpiredRelevantDateOnWorldCardsJob < ApplicationJob
  # == Configuration ==

  limits_concurrency key: :global, on_conflict: :discard

  # == Job ==

  sig { void }
  def perform
    WorldCard.with_expired_relevant_date
      .find_each(&:clear_relevant_date!)
  end
end
