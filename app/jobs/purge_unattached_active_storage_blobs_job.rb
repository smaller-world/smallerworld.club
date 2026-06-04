# typed: strict
# frozen_string_literal: true

class PurgeUnattachedActiveStorageBlobsJob < ApplicationJob
  # == Configuration ==

  limits_concurrency key: :global, on_conflict: :discard

  # == Job ==

  sig { void }
  def perform
    ActiveStorage::Blob
      .unattached
      .where(active_storage_blobs: { created_at: ..2.days.ago })
      .find_each(&:purge_later)
  end
end
