# typed: true
# frozen_string_literal: true

require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:jane)
      @user = users(:bob)
    end

    test "an admin sees the dashboard" do
      sign_in_as(@admin)
      with_admins(@admin) do
        get admin_dashboard_path
      end
      assert_response :success
      assert_select "a[href=?]", admin_reports_path
    end

    test "admin routes return 403 to signed-in non-admins" do
      world = create_world(owner: users(:sue))
      key = create_member_key(world:, recipient: @user)
      reported_post = create_post(world:, visible_to_key_type_ids: [ key.type_id ])
      report = reported_post.reports.create!(reporter: @user, category: "spam")
      sign_in_as(@user)

      with_admins(@admin) do
        [
          admin_dashboard_path,
          admin_reports_path,
          admin_report_path(report),
        ].each do |path|
          get(path)
          assert_response(:forbidden, "GET #{path}")
        end

        path = resolve_admin_report_path(report)
        post(path, params: { report: { resolution: "dismissed" } })
        assert_response(:forbidden, "POST #{path}")
        assert_nil report.reload.resolution

        get admin_mission_control_jobs_path
        assert_response :forbidden
      end
    end

    test "an admin can load mission control" do
      sign_in_as(@admin)
      with_admins(@admin) do
        get admin_mission_control_jobs_path
      end
      assert_response :success
    end
  end
end
