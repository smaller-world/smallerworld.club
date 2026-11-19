# typed: strict
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

  test "a signed-out visitor sees a reporting alert in place of a reported post" do
    reporter = users(:sue)
    create_member_key(world: @world, recipient: reporter)
    post = create_post(world: @world, body: "reported post body")
    post.reports.create!(reporter:, category: "spam")

    get post_path(post)

    assert_response :success
    assert_not_includes response.body, "reported post body"
    assert_select '[role="alert"]', text: "this post has been reported."
  end

  test "the author can open a reported post's secret link after the report is upheld" do
    reporter = users(:sue)
    create_member_key(world: @world, recipient: reporter)
    post = create_post(world: @world, body: "the author's reported post body")
    report = post.reports.create!(reporter:, category: "spam")
    report.resolve!(resolution: "upheld", moderator: users(:jane))
    sign_in_as(@owner)

    get post_path(post)

    assert_response :success
    assert_includes response.body, "the author's reported post body"
  end

  test "a friend sees a reporting alert on the secret link after the report is upheld" do
    friend = users(:sue)
    create_member_key(world: @world, recipient: friend)
    post = create_post(world: @world, body: "post shared with a friend")
    report = post.reports.create!(reporter: friend, category: "spam")
    report.resolve!(resolution: "upheld", moderator: users(:jane))
    sign_in_as(friend)

    get post_path(post)

    assert_response :success
    assert_not_includes response.body, "post shared with a friend"
    assert_select '[role="alert"]', text: "this post has been reported."
  end

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

  test "encrypted rich text loads into the editor and preserves formatting in the feed" do
    post = create_post(world: @world, body: "<p><s>crossed out</s> <u>underlined</u></p>")
    sign_in_as(@owner)

    get edit_post_path(post)
    assert_response :success
    assert_select "lexxy-editor[name='post[body]']" do |editors|
      value = editors.first["value"].to_s
      assert_includes value, "<s>crossed out</s>"
      assert_includes value, "<u>underlined</u>"
    end

    get world_posts_path(@world), headers: { "Turbo-Frame" => "posts" }
    assert_response :success
    assert_select ".lexxy-content s", text: "crossed out"
    assert_select ".lexxy-content u", text: "underlined"
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

  test "a signed-in user without a key cannot open the world feed" do
    create_post(world: @world, body: "post in a private world")
    sign_in_as(users(:sue))

    get world_posts_path(@world),
      headers: { "Turbo-Frame" => "posts" }

    assert_response :forbidden
    assert_not_includes response.body, "post in a private world"
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

    sign_in_as(@owner)
    post world_posts_path(@world), params: {
      post: {
        type_id: post_type.id,
        body: "<div>secret post</div>",
        recipient_ids: [ visible_friend.id ],
      },
    }
    post = @world.posts.chronological.last!
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
