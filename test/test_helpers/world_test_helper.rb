# typed: strict
# frozen_string_literal: true

# Dumb, composable builders for world-related records. No conditional logic —
# combine them to express scenarios. See docs/testing.md.
module WorldTestHelper
  extend T::Sig

  # == Configuration ==

  WORLD_ICON_PATH = T.let(Rails.root.join("test/fixtures/files/world_icon.png"), Pathname)

  # == Methods ==

  # Creates a world owned by `owner` with the canonical icon attached
  # (icon is a required attachment).
  sig { params(owner: User, name: T.nilable(String)).returns(World) }
  def create_world(owner:, name: nil)
    world = owner.owned_worlds.build
    world.name = name if name
    world.icon.attach(
      io: File.open(WORLD_ICON_PATH),
      filename: "world_icon.png",
      content_type: "image/png",
    )
    world.save!
    world
  end

  # Grants `recipient` a key to `world`. The "join" primitive.
  # `accepted: false` models the future return-key (pending) invite.
  sig do
    params(world: World, recipient: User, color: Symbol, accepted: T::Boolean)
      .returns(WorldKey)
  end
  def grant_key(world:, recipient:, color:, accepted: true)
    world.keys.create!(
      recipient:,
      color:,
      accepted_at: accepted ? Time.current : nil,
    )
  end

  # Creates a key-scoped post. `key_colors: nil` means visible to all keys.
  sig do
    params(
      world: World,
      key_colors: T.nilable(T::Array[Symbol]),
      body: String,
      attrs: T.untyped,
    ).returns(Post)
  end
  def create_post(world:, key_colors: nil, body: "hello world", **attrs)
    if key_colors
      key_colors = key_colors.map(&:to_s)
    end
    world.posts.create!(body:, key_colors:, **attrs)
  end
end

ActiveSupport.on_load(:active_support_test_case) do
  include WorldTestHelper
end
