# typed: true
# frozen_string_literal: true

require "test_helper"

class ReactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = T.let(users(:bob), User)
    @friend = T.let(users(:sue), User)
    @world = T.let(create_world(owner: @owner, name: "Reacting World"), World)
    create_member_key(world: @world, recipient: @friend)
    @post = T.let(create_post(world: @world), Post)
  end

  test "a member adds a reaction" do
    sign_in_as(@friend)
    assert_difference -> { @post.reactions.count }, 1 do
      post post_reactions_path(@post),
        params: {
          reaction: {
            emoji: "🔥",
          },
        }
    end
    assert_redirected_to post_reactions_path(@post)
  end

  test "a member removes their reaction" do
    reaction = @post.reactions.create!(reactor: @friend, emoji: "🔥")

    sign_in_as(@friend)
    assert_difference -> { @post.reactions.count }, -1 do
      delete reaction_path(reaction)
    end
    assert_redirected_to post_reactions_path(@post)
  end
end
