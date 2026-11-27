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
    world.post_types = PostType.default_types
    world.icon.attach(
      io: File.open(WORLD_ICON_PATH),
      filename: "world_icon.png",
      content_type: "image/png",
    )
    world.save!
    world
  end

  sig do
    params(
      world: World,
      type_name: String,
      body: String,
      attributes: T.untyped,
    ).returns(Post)
  end
  def create_post(world:, type_name: "journal entry", body: "hello world", **attributes)
    world.posts.create!(
      type: post_type_for(world, type_name),
      body:,
      **attributes,
    )
  end

  sig { params(world: World, recipient: User).returns(WorldKey) }
  def create_member_key(world:, recipient:)
    type = world.key_types.find_or_create_by!(name: "new friends") { |key_type| key_type.color = "green" }
    world.keys.create!(recipient:, type:)
  end

  private

  # == Helpers ==

  sig { params(world: World, name: String).returns(PostType) }
  def post_type_for(world, name)
    world.post_types.find_by!(name:)
  end
end

ActiveSupport.on_load(:active_support_test_case) do
  include WorldTestHelper
end
