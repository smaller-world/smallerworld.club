# typed: strict
# frozen_string_literal: true

class ImportV1PostsJob < ApplicationJob
  # == Configuration ==

  # Only one import job may run per user at a time.
  limits_concurrency key: ->(world) { world }, on_conflict: :discard

  # == Job ==

  sig { params(world: World).void }
  def perform(world)
    world.import_v1_posts!
  end
end
