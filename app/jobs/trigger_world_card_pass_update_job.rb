# typed: strict
# frozen_string_literal: true

class TriggerWorldCardPassUpdateJob < ApplicationJob
  # == Configuration ==

  limits_concurrency key: ->(card) { card }, on_conflict: :discard

  # == Job ==

  sig { params(world_card: WorldCard).void }
  def perform(world_card)
    world_card.trigger_pass_update
  end
end
