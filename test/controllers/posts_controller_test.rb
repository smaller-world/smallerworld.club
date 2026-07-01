# typed: true
# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include ActionView::RecordIdentifier

  # == Configuration ==

  setup do
    @owner = T.let(users(:bob), User)
    @world = T.let(create_world(owner: @owner, name: "Posting World"), World)
  end

  # == Tests ==

  test "owner creates a post of a given type" do
    sign_in_as(@owner)
    post_type = @world.post_types.find_by!(label: "journal entry")

    assert_difference -> { @world.posts.count }, 1 do
      post world_posts_path(@world), params: {
        post: {
          type_id: post_type.id,
          title: "Hello",
          body: "body text",
        },
      }
    end
    post = @world.posts.chronological.last!
    assert_equal post_type, post.type
    assert_redirected_to world_path(@world, anchor: dom_id(post, :card))
  end

  test "owner edits a post" do
    post = create_post(world: @world, body: "original")

    sign_in_as(@owner)
    put post_path(post),
      params: {
        post: {
          title: "Edited",
          body: "original",
        },
      }
    assert_redirected_to world_path(@world, anchor: dom_id(post, :card))
    assert_equal "Edited", post.reload.title
  end

  test "owner deletes a post" do
    post = create_post(world: @world)

    sign_in_as(@owner)
    assert_difference -> { @world.posts.count }, -1 do
      delete post_path(post), as: :turbo_stream
    end
    assert_redirected_to world_path(@world)
  end

  test "owner views the world feed via turbo frame" do
    create_post(world: @world, body: "visible post")

    sign_in_as(@owner)
    get world_posts_path(@world),
      headers: { "Turbo-Frame" => "posts" }
    assert_response :success
    assert_includes response.body, "visible post"
  end

  test "a friend sees only the posts of the types their key grants" do
    friend = users(:sue)
    @world.post_types.create!(label: "diary")
    key = @world.keys.create!(recipient: friend)
    key.granted_post_types << @world.post_types.find_by!(label: "journal entry")

    create_post(world: @world, body: "granted post")
    create_post(world: @world, type_label: "diary", body: "ungranted post")

    sign_in_as(friend)
    get world_posts_path(@world),
      headers: { "Turbo-Frame" => "posts" }
    assert_response :success
    assert_includes response.body, "granted post"
    assert_not_includes response.body, "ungranted post"
  end
end
