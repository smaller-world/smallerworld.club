# typed: true
# frozen_string_literal: true

class ReconcileWhatsappGroupMembershipsJob < ApplicationJob
  # == Configuration ==

  queue_as :default
  limits_concurrency key: :global, on_conflict: :discard

  # == Job ==

  sig { void }
  def perform
    WhatsappGroup
      .where(memberships_imported_at: nil)
      .or(WhatsappGroup.where(memberships_imported_at: ...1.day.ago))
      .find_each(&:import_memberships_later)
  end
end
