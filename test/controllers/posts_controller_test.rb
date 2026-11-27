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
    key = create_member_key(world: @world, recipient: reporter)
    post = create_post(world: @world, body: "reported post body", visible_to_key_type_ids: [ key.type_id ])
    post.reports.create!(reporter:, category: "spam")

    get post_path(post)

    assert_response :success
    assert_not_includes response.body, "reported post body"
    assert_select '[role="alert"]', text: /\breported\b/i
  end

  test "the author can open a reported post's secret link after the report is upheld" do
    reporter = users(:sue)
    key = create_member_key(world: @world, recipient: reporter)
    post = create_post(world: @world, body: "the author's reported post body", visible_to_key_type_ids: [ key.type_id ])
    report = post.reports.create!(reporter:, category: "spam")
    report.resolve!(resolution: "upheld", moderator: users(:jane))
    sign_in_as(@owner)

    get post_path(post)

    assert_response :success
    assert_includes response.body, "the author's reported post body"
  end

  test "a friend sees a reporting alert on the secret link after the report is upheld" do
    friend = users(:sue)
    key = create_member_key(world: @world, recipient: friend)
    post = create_post(world: @world, body: "post shared with a friend", visible_to_key_type_ids: [ key.type_id ])
    report = post.reports.create!(reporter: friend, category: "spam")
    report.resolve!(resolution: "upheld", moderator: users(:jane))
    sign_in_as(friend)

    get post_path(post)

    assert_response :success
    assert_not_includes response.body, "post shared with a friend"
    assert_select '[role="alert"]', text: /\breported\b/i
  end

  test "owner creates a post of a given type" do
    sign_in_as(@owner)
    post_type = @world.post_types.find_by!(name: "journal entry")

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

  test "a friend sees only the posts shared with their key type" do
    friend = users(:sue)
    key_type = WorldKeyType.create!(world: @world, name: "close friends", color: "pink")
    @world.keys.create!(recipient: friend, type_id: key_type.id)

    create_post(world: @world, body: "shared post", visible_to_key_type_ids: [ key_type.id ])
    create_post(world: @world, body: "private post")

    sign_in_as(friend)
    get world_posts_path(@world),
      headers: { "Turbo-Frame" => "posts" }
    assert_response :success
    assert_includes response.body, "shared post"
    assert_not_includes response.body, "private post"
  end

  test "publishing with a selected key type shares the post with its holders" do
    friend = users(:sue)
    key_type = WorldKeyType.create!(world: @world, name: "close friends", color: "pink")
    @world.keys.create!(recipient: friend, type_id: key_type.id)
    post_type = @world.post_types.find_by!(name: "journal entry")

    sign_in_as(@owner)
    post world_posts_path(@world), params: {
      post: {
        type_id: post_type.id,
        body: "<div>secret post</div>",
        visible_to_key_type_ids: [ key_type.id ],
      },
    }
    post = @world.posts.chronological.last!
    assert_equal "secret post", post.plain_body

    sign_in_as(friend)
    get world_posts_path(@world),
      headers: { "Turbo-Frame" => "posts" }
    assert_response :success
    assert_includes response.body, "secret post"
  end

  test "publishing keeps only key types from the post's world" do
    other_world = create_world(owner: @owner, name: "Other World")
    foreign_type = WorldKeyType.create!(world: other_world, name: "close friends", color: "pink")
    local_type = WorldKeyType.create!(world: @world, name: "close friends", color: "pink")
    post_type = @world.post_types.find_by!(name: "journal entry")
    sign_in_as(@owner)

    assert_difference -> { @world.posts.count }, 1 do
      post world_posts_path(@world), params: {
        post: {
          type_id: post_type.id,
          body: "post with a selected key type",
          visible_to_key_type_ids: [ local_type.id, SecureRandom.uuid, foreign_type.id ],
        },
      }
    end
    assert_response :redirect
    assert_equal [ local_type.id ], @world.posts.chronological.last!.visible_to_key_type_ids
  end

  test "editing preserves an omitted audience and clears an explicitly empty one" do
    friend = users(:sue)
    key_type = WorldKeyType.create!(world: @world, name: "close friends", color: "pink")
    @world.keys.create!(recipient: friend, type_id: key_type.id)
    shared_post = create_post(world: @world, visible_to_key_type_ids: [ key_type.id ])
    recipient = open_session { |client| client.sign_in_as(friend) }
    feed_path = world_posts_path(@world)
    feed_headers = { "Turbo-Frame" => "posts" }
    sign_in_as(@owner)

    patch post_path(shared_post), params: { post: { body: "edited post" } }
    assert_response :redirect
    recipient.get(feed_path, headers: feed_headers)
    recipient.assert_response(:success)
    assert_includes recipient.response.body, "edited post"

    patch post_path(shared_post),
      params: { post: { visible_to_key_type_ids: [] } },
      as: :json,
      headers: { "Accept" => "text/html" }
    assert_response :redirect
    recipient.get(feed_path, headers: feed_headers)
    recipient.assert_response(:success)
    assert_not_includes recipient.response.body, "edited post"
  end
end
