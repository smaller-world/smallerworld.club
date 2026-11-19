# typed: strict
# frozen_string_literal: true

require "test_helper"

class PostReportsControllerTest < ActionDispatch::IntegrationTest
  test "reporting a post hides it from the reporter but keeps it visible to its author" do
    author = users(:bob)
    reporter = users(:sue)
    world = create_world(owner: author)
    create_member_key(world:, recipient: reporter)
    body = "Post that will be reported"
    reported_post = create_post(world:, body:)
    feed_path = world_posts_path(world)
    headers = { "Turbo-Frame" => "posts" }

    sign_in_as(reporter)
    get(feed_path, headers:)
    assert_response :success
    assert_includes response.body, body

    post post_reports_path(reported_post), params: { report: { category: "spam" } }
    assert_redirected_to world_path(world)

    get(feed_path, headers:)
    assert_response :success
    assert_not_includes response.body, body

    sign_in_as(author)
    get(feed_path, headers:)
    assert_response :success
    assert_includes response.body, body
  end
end
