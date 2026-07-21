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

  test "a post deselecting one recipient stays visible to the others" do
    hidden_friend = users(:sue)
    visible_friend = users(:jane)
    create_member_key(world: @world, recipient: hidden_friend)
    create_member_key(world: @world, recipient: visible_friend)
    post_type = @world.post_types.find_by!(label: "journal entry")

    # The compose UI submits the *selected* recipients (`recipient_ids`). The
    # model stores the inverse (`hidden_from_ids`) so members added later still
    # see the post by default. Here the owner deselects `hidden_friend`, keeping
    # only `visible_friend`. `body` is ActionText rich text, submitted as HTML.
    sign_in_as(@owner)
    post world_posts_path(@world), params: {
      post: {
        type_id: post_type.id,
        body: "<div>secret post</div>",
        recipient_ids: [ visible_friend.id ],
      },
    }
    post = @world.posts.chronological.last!
    assert_equal [ hidden_friend.id ], post.hidden_from_ids
    assert_equal "secret post", post.plain_body

    # `hidden_friend` was deselected, so the post is absent from their feed.
    sign_in_as(hidden_friend)
    get world_posts_path(@world),
      headers: { "Turbo-Frame" => "posts" }
    assert_response :success
    assert_not_includes response.body, "secret post"

    # `visible_friend` was kept as a recipient, so the post appears in theirs.
    sign_in_as(visible_friend)
    get world_posts_path(@world),
      headers: { "Turbo-Frame" => "posts" }
    assert_response :success
    assert_includes response.body, "secret post"
  end
end
