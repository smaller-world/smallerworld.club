# typed: true
# frozen_string_literal: true

class ImportLumaEventsJob < ApplicationJob
  # == Configuration ==

  queue_as :default
  limits_concurrency key: :global, on_conflict: :discard

  # == Job ==

  sig { void }
  def perform
    tag_logger do
      events = Event.import_from_luma
      logger.info("Imported #{events.size} upcoming events from Luma")
    end
  end
end
