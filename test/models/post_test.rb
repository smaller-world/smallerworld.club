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
    @secret_type = @world.post_types.create!(label: "secret diary", secret: true)
  end

  test "the owner sees posts of every type in their world" do
    public_post = create_post(world: @world)
    secret_post = create_post(world: @world, type_label: "secret diary")

    scope = Post.visible_to(@owner)
    assert_includes scope, public_post
    assert_includes scope, secret_post
  end

  test "a key holder sees posts of all non-secret types" do
    @world.keys.create!(recipient: @friend)
    post = create_post(world: @world)

    assert_includes Post.visible_to(@friend), post
  end

  test "a key holder does not see secret posts their key does not grant" do
    @world.keys.create!(recipient: @friend)
    secret_post = create_post(world: @world, type_label: "secret diary")

    assert_not_includes Post.visible_to(@friend), secret_post
  end

  test "a key holder sees secret posts their key grants" do
    key = @world.keys.create!(recipient: @friend)
    key.granted_post_types << @secret_type
    secret_post = create_post(world: @world, type_label: "secret diary")

    assert_includes Post.visible_to(@friend), secret_post
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
