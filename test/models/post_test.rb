# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: posts
#
#  id            :uuid             not null, primary key
#  emoji         :string
#  plain_body    :text             not null
#  quiet         :boolean          default(FALSE), not null
#  title         :string
#  v1_attributes :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  type_id       :uuid             not null
#
# Indexes
#
#  index_posts_on_quiet    (quiet)
#  index_posts_on_type_id  (type_id)
#
# Foreign Keys
#
#  fk_rails_...  (type_id => post_types.id)
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

  test "a key holder sees posts of the types their key grants" do
    key = @world.keys.create!(recipient: @friend)
    key.granted_post_types << post_type_for(@world, "journal entry")
    post = create_post(world: @world)

    assert_includes Post.visible_to(@friend), post
  end

  test "a key holder does not see posts of types their key does not grant" do
    @world.keys.create!(recipient: @friend)
    diary_post = create_post(world: @world, type_label: "diary")

    assert_not_includes Post.visible_to(@friend), diary_post
  end

  test "a key holder sees only the types their key grants" do
    key = @world.keys.create!(recipient: @friend)
    key.granted_post_types << post_type_for(@world, "journal entry")

    granted_post = create_post(world: @world)
    ungranted_post = create_post(world: @world, type_label: "diary")

    scope = Post.visible_to(@friend)
    assert_includes scope, granted_post
    assert_not_includes scope, ungranted_post
  end

  test "a non-member sees nothing" do
    post = create_post(world: @world)

    assert_not_includes Post.visible_to(@friend), post
  end

  private

  # Asserts the block touches `card` (advances `updated_at`). Time is advanced
  # so the touch writes a strictly later timestamp than the one captured before.
  def assert_card_touched(card, &block)
    before = card.reload.updated_at
    travel(1.minute, &block)
    assert_operator(
      card.reload.updated_at,
      :>,
      before,
      "expected the card to be touched",
    )
  end

  def assert_card_untouched(card, &block)
    before = card.reload.updated_at
    travel(1.minute, &block)
    assert_equal(
      before,
      card.reload.updated_at,
      "expected the card to be left untouched",
    )
  end
end
