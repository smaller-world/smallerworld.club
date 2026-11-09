# typed: true
# frozen_string_literal: true

require "test_helper"

class UserReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reporter = users(:sue)
    @reported = users(:bob)
    @world = worlds(:bobs_world_one)
    @keys = @reported.owned_worlds.map do |world|
      create_member_key(world:, recipient: @reporter)
    end
    @keys << create_member_key(world: worlds(:sues_world), recipient: @reported)
    sign_in_as(@reporter)
  end

  test "reporting an account removes all world keys in both directions" do
    unrelated_key = create_member_key(world: @world, recipient: users(:jane))
    assert_difference "Report.count", 1 do
      assert_difference "WorldKey.count", -@keys.size do
        assert_no_difference "World.count" do
          post user_reports_path(@reported), params: { report: { category: "spam" } }
        end
      end
    end

    assert_redirected_to home_path
    assert_empty WorldKey.where(id: @keys.map(&:id))
    assert_empty PostTypeGrant.where(world_key_id: @keys.map(&:id))
    report = Report.last!
    assert_equal @reported, report.reportable
    assert_equal @reporter, report.reporter
    assert WorldKey.exists?(unrelated_key.id)
  end

  test "a failed key removal rolls back the report and all key removals" do
    blocked_key_id = @keys.last.id
    prevent_destroy = ->(key) { throw :abort if key.id == blocked_key_id }
    WorldKey.set_callback(:destroy, :before, prevent_destroy)

    assert_no_difference [ "Report.count", "WorldKey.count" ] do
      assert_raises ActiveRecord::RecordNotDestroyed do
        post user_reports_path(@reported), params: { report: { category: "spam" } }
      end
    end
  ensure
    WorldKey.skip_callback(:destroy, :before, prevent_destroy)
  end

  test "an invalid report preserves keys and renders the form" do
    assert_no_difference [ "Report.count", "WorldKey.count" ] do
      post user_reports_path(@reported), params: {
        world_id: @world.id,
        report: { category: "other", note: "" },
      }
    end

    assert_response :unprocessable_content
  end

  test "a user without a key cannot report the owner or remove keys" do
    sign_in_as(users(:jane))

    assert_no_difference [ "Report.count", "WorldKey.count" ] do
      post user_reports_path(@reported), params: { report: { category: "spam" } }
    end

    assert_response :forbidden
  end
end
