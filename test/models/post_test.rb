# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: posts
#
#  id                            :uuid             not null, primary key
#  emoji                         :string
#  favorited_at                  :timestamptz
#  hidden_from_user_ids          :uuid             default([]), not null, is an Array
#  ordered_images_attachment_ids :uuid             default([]), not null, is an Array
#  plain_body                    :text             not null
#  quiet                         :boolean          default(FALSE), not null
#  title                         :string
#  v1_attributes                 :jsonb
#  visible_to_key_type_ids       :uuid             default([]), not null, is an Array
#  visible_to_user_ids           :uuid             default([]), not null, is an Array
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  type_id                       :uuid             not null
#  world_id                      :uuid             not null
#
# Indexes
#
#  index_posts_on_favorited_at            (favorited_at)
#  index_posts_on_hidden_from_user_ids    (hidden_from_user_ids) USING gin
#  index_posts_on_quiet                   (quiet)
#  index_posts_on_type_id_and_created_at  (type_id,created_at)
#  index_posts_on_world_id                (world_id)
#
# Foreign Keys
#
#  fk_rails_...  ([type_id, world_id] => post_types[id, world_id])
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @owner = users(:bob)
    @friend = users(:sue)
    @world = create_world(owner: @owner, name: "Visibility World")
    @diary_type = @world.post_types.create!(label: "diary")
  end

  test "the owner sees posts of every type in their world" do
    journal_post = create_post(world: @world)
    diary_post = create_post(world: @world, type_label: "diary")

    scope = Post.visible_to(@owner)
    assert_includes scope, journal_post
    assert_includes scope, diary_post
  end

  test "a current key alone does not grant access to a post" do
    create_typed_friend_key
    post = create_post(world: @world)

    assert_not_includes Post.visible_to(@friend), post
  end

  test "a non-member sees nothing" do
    post = create_post(world: @world)

    assert_not_includes Post.visible_to(@friend), post
  end

  test "the key audience includes a friend with a selected key type" do
    key = create_typed_friend_key
    post = create_post(world: @world, visible_to_key_type_ids: [ key.type_id ])

    assert_includes Post.visible_to(@friend), post
  end

  test "the key audience includes a friend selected individually" do
    create_typed_friend_key
    post = create_post(world: @world, visible_to_user_ids: [ @friend.id ])

    assert_includes Post.visible_to(@friend), post
  end

  test "an individual exclusion overrides a selected key type" do
    key = create_typed_friend_key
    post = create_post(
      world: @world,
      visible_to_key_type_ids: [ key.type_id ],
      hidden_from_user_ids: [ @friend.id ],
    )

    assert_not_includes Post.visible_to(@friend), post
  end

  test "an individual exclusion overrides an individual inclusion" do
    create_typed_friend_key
    post = create_post(
      world: @world,
      visible_to_user_ids: [ @friend.id ],
      hidden_from_user_ids: [ @friend.id ],
    )

    assert_not_includes Post.visible_to(@friend), post
  end

  test "an individual inclusion stops applying when the key is revoked" do
    key = create_typed_friend_key
    post = create_post(world: @world, visible_to_user_ids: [ @friend.id ])
    assert Post.visible_to(@friend).exists?(post.id)
    key.destroy!
    assert_not Post.visible_to(@friend).exists?(post.id)
  end

  test "an individual inclusion cannot use a key from another world" do
    key = create_typed_friend_key
    post = create_post(world: @world, visible_to_user_ids: [ @friend.id ])
    key.destroy!
    other_world = create_world(owner: @owner, name: "Other World")
    create_typed_friend_key(world: other_world)

    assert_not_includes Post.visible_to(@friend), post
  end

  test "individual exceptions only save IDs for current key holders" do
    create_typed_friend_key
    ids = [ @friend.id, users(:jane).id, SecureRandom.uuid ]
    post = create_post(world: @world, visible_to_user_ids: ids, hidden_from_user_ids: ids)

    assert_equal [ @friend.id ], post.reload.visible_to_user_ids
    assert_equal [ @friend.id ], post.hidden_from_user_ids
  end

  test "editing a post removes individual exceptions for a revoked key" do
    key = create_typed_friend_key
    ids = [ @friend.id ]
    post = create_post(world: @world, visible_to_user_ids: ids, hidden_from_user_ids: ids)
    key.destroy!

    post.update!(body: "updated post")

    assert_empty post.reload.visible_to_user_ids
    assert_empty post.hidden_from_user_ids
  end

  private

  def create_typed_friend_key(world: @world)
    type = WorldKeyType.create!(world:, name: "close friends", color: "pink")
    world.keys.create!(recipient: @friend, type_id: type.id)
  end
end
