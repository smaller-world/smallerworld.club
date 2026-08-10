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

    test "a non-admin gets a 401" do
      sign_in_as(@user)
      with_admins(@admin) do
        get admin_dashboard_path
      end
      assert_response :not_authorized
    end

    test "mission control is gated by the admin filter" do
      sign_in_as(@user)
      with_admins(@admin) do
        get admin_mission_control_jobs_path
      end
      assert_response :not_authorized
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
