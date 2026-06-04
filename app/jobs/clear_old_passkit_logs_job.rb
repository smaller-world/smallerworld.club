# typed: strict
# frozen_string_literal: true

class ClearOldPasskitLogsJob < ApplicationJob
  # == Configuration ==

  limits_concurrency key: :global, on_conflict: :discard

  # == Job ==

  sig { void }
  def perform
    Passkit::Log.where(created_at: ..2.weeks.ago).delete_all
  end
end
