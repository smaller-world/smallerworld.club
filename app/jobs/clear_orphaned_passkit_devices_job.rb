# typed: strict
# frozen_string_literal: true

class ClearOrphanedPasskitDevicesJob < ApplicationJob
  # == Configuration ==

  limits_concurrency key: :global, on_conflict: :discard

  # == Job ==

  sig { void }
  def perform
    Passkit::Device.where.missing(:registrations).delete_all
  end
end
