# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: posts
#
#  id         :uuid             not null, primary key
#  emoji      :string
#  key_colors :string           is an Array
#  plain_body :text             not null
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  world_id   :uuid             not null
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
end
