# typed: true
# frozen_string_literal: true

require "test_helper"

module Admin
  class ReportsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:jane)
      @owner = users(:bob)
      @reporter = users(:sue)
      @world = create_world(owner: @owner)
      @post = create_post(world: @world)
      create_member_key(world: @world, recipient: @reporter)
      @report = @post.reports.create!(reporter: @reporter, category: "spam")
    end

    test "a signed-out visitor is sent to sign in" do
      get admin_reports_path
      assert_redirected_to new_session_path
    end

    test "an admin sees the reports index" do
      sign_in_as(@admin)
      with_admins(@admin) do
        get admin_reports_path
      end
      assert_response :success
      assert_select "a[href=?]", admin_report_path(@report)
    end

    test "an admin sees a report and the reported content" do
      sign_in_as(@admin)
      with_admins(@admin) do
        get admin_report_path(@report)
      end
      assert_response :success
      assert_select "body", text: /hello world/
    end

    test "upholding keeps the post hidden from recipients" do
      sign_in_as(@admin)
      with_admins(@admin) do
        post resolve_admin_report_path(@report), params: {
          report: { resolution: "upheld" },
        }
      end
      assert_redirected_to admin_report_path(@report)

      @report.reload
      assert_equal "upheld", @report.resolution
      assert_equal @admin, @report.moderator
      assert_not @post.reload.visible_to?(@reporter)
    end

    test "dismissing restores the post for recipients" do
      assert_not @post.visible_to?(@reporter),
        "a pending report should hide the post"

      sign_in_as(@admin)
      with_admins(@admin) do
        post resolve_admin_report_path(@report), params: {
          report: { resolution: "dismissed" },
        }
      end

      assert_equal "dismissed", @report.reload.resolution
      assert @post.reload.visible_to?(@reporter)
    end

    test "reversing an upheld report restores the post to the recipient's feed" do
      sign_in_as(@admin)
      recipient = open_session { |client| client.sign_in_as(@reporter) }
      feed_path = world_posts_path(@world)
      headers = { "Turbo-Frame" => "posts" }

      with_admins(@admin) do
        post resolve_admin_report_path(@report), params: {
          report: { resolution: "upheld" },
        }
        assert_equal "upheld", @report.reload.resolution
        recipient.get(feed_path, headers:)
        recipient.assert_response(:success)
        assert_not_includes recipient.response.body, "hello world"

        post resolve_admin_report_path(@report), params: {
          report: { resolution: "dismissed" },
        }
      end
      assert_equal "dismissed", @report.reload.resolution
      recipient.get(feed_path, headers:)
      recipient.assert_response(:success)
      assert_includes recipient.response.body, "hello world"
    end
  end
end
