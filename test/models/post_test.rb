# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: posts
#
#  id            :uuid             not null, primary key
#  emoji         :string
#  key_colors    :string           is an Array
#  plain_body    :text             not null
#  title         :string
#  v1_attributes :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  world_id      :uuid             not null
#
# Indexes
#
#  index_posts_on_key_colors  (key_colors)
#  index_posts_on_world_id    (world_id)
#
# Foreign Keys
#
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @owner = users(:bob)
    @friend = users(:sue)
    @world = create_world(owner: @owner, name: "Visibility World")
  end

  test "the owner sees all posts in their world" do
    post = create_post(world: @world, key_colors: [ :red ])

    assert_includes Post.visible_to(@owner), post
  end

  test "a key holder sees posts scoped to their key color" do
    grant_key(world: @world, recipient: @friend, color: :blue)
    visible = create_post(world: @world, key_colors: [ :blue ])
    hidden = create_post(world: @world, key_colors: [ :red ])

    scope = Post.visible_to(@friend)
    assert_includes scope, visible
    assert_not_includes scope, hidden
  end

  test "a key holder sees posts with no color restriction" do
    grant_key(world: @world, recipient: @friend, color: :blue)
    post = create_post(world: @world, key_colors: nil)

    assert_includes Post.visible_to(@friend), post
  end

  test "a non-member sees nothing" do
    post = create_post(world: @world, key_colors: nil)

    assert_not_includes Post.visible_to(@friend), post
  end

  test "creating the latest post touches the world's cards" do
    card = @world.cards.create!(granted_key_color: :blue)

    assert_card_touched(card) do
      create_post(world: @world)
    end
  end

  test "creating a post that is not the latest leaves the world's cards untouched" do
    card = @world.cards.create!(granted_key_color: :blue)
    create_post(world: @world) # the latest post

    assert_card_untouched(card) do
      create_post(world: @world, created_at: 1.day.ago)
    end
  end

  test "destroying the latest post touches the world's cards" do
    card = @world.cards.create!(granted_key_color: :blue)
    create_post(world: @world, created_at: 2.days.ago)
    latest = create_post(world: @world, created_at: 1.day.ago)

    assert_card_touched(card) do
      latest.destroy!
    end
  end

  test "destroying a post that is not the latest leaves the world's cards untouched" do
    card = @world.cards.create!(granted_key_color: :blue)
    older = create_post(world: @world, created_at: 2.days.ago)
    create_post(world: @world, created_at: 1.day.ago) # the latest post

    assert_card_untouched(card) do
      older.destroy!
    end
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
