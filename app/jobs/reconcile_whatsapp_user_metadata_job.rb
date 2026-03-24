# typed: true
# frozen_string_literal: true

class ReconcileWhatsappUserMetadataJob < ApplicationJob
  # == Configuration ==

  queue_as :default
  limits_concurrency key: :global, on_conflict: :discard

  # == Job ==

  sig { void }
  def perform
    WhatsappUser
      .where(metadata_imported_at: nil)
      .or(WhatsappUser.where(metadata_imported_at: ...1.day.ago))
      .find_each(&:import_metadata_later)
  end
end
