# typed: true
# frozen_string_literal: true

module WorldsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  # == Methods ==

  sig do
    params(
      world: World,
      friend_token: T.nilable(String),
      options: T.untyped,
    ).returns(String)
  end
  def user_aware_world_path(world, friend_token: nil, **options)
    if allowed_to?(:manage?, world)
      user_world_path(**options)
    else
      world_path(world, friend_token:, **options)
    end
  end

  sig do
    params(
      world: World,
      friend_token: T.nilable(String),
      options: T.untyped,
    ).returns(String)
  end
  def user_aware_world_url(world, friend_token: nil, **options)
    if allowed_to?(:manage?, world)
      user_world_url(**options)
    else
      world_url(world, friend_token:, **options)
    end
  end
end
