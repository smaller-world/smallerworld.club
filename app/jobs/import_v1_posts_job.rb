# typed: strict
# frozen_string_literal: true

class ImportV1PostsJob < ApplicationJob
  # == Configuration ==

  # Only one import job may run per world at a time.
  limits_concurrency key: ->(world, **_options) { world }, on_conflict: :discard

  # == Job ==

  sig do
    params(
      world: World,
      last_imported_post_created_at: T.nilable(Time),
      limit: T.nilable(Integer),
    ).void
  end
  def perform(
    world,
    last_imported_post_created_at: nil,
    limit: nil
  )
    world.import_v1_posts!(limit:)
  end
end
