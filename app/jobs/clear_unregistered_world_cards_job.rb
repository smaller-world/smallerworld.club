# typed: strict
# frozen_string_literal: true

class ClearUnregisteredWorldCardsJob < ApplicationJob
  # == Configuration ==

  limits_concurrency key: :global, on_conflict: :discard

  # == Job ==

  sig { void }
  def perform
    unregistered_passes = Passkit::Pass.where.missing(:registrations)
      .where(updated_at: ..1.week.ago)
    WorldCard.where.missing(:pass)
      .or(WorldCard.where(pass: unregistered_passes))
      .destroy_all
  end
end
