# typed: strict
# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated visitor is redirected to sign in" do
    get home_path
    assert_redirected_to new_session_path
  end

  test "orders a friend's worlds by the latest post they can see after moderation" do
    friend = users(:sue)
    owner = users(:bob)
    older_world, newer_world = travel_to(4.hours.ago) do
      [ create_world(owner:, name: "Older World"), create_world(owner:, name: "Newer World") ]
    end
    create_member_key(world: older_world, recipient: friend)
    create_member_key(world: newer_world, recipient: friend)
    create_post(world: older_world, created_at: 3.hours.ago)
    create_post(world: newer_world, created_at: 2.hours.ago)
    newest_post = create_post(world: older_world, created_at: 1.hour.ago)
    report = newest_post.reports.create!(reporter: friend, category: "spam")
    moderator = users(:jane)
    sign_in_as(friend)

    world_paths = [ world_path(older_world), world_path(newer_world) ]
    [ nil, "upheld", "dismissed" ].each do |resolution|
      report.resolve!(resolution:, moderator:) if resolution
      get home_path

      assert_response :success
      links = css_select("a[href]").map { |link| link["href"] } & world_paths
      expected = resolution == "dismissed" ? world_paths : world_paths.reverse
      assert_equal expected, links, "world order with a #{resolution || 'pending'} report"
    end
  end
end
