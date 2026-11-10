# typed: true
# frozen_string_literal: true

require "test_helper"

module Admin
  class UsersControllerTest < ActiveSupport::TestCase
    setup do
      @controller = UsersController.new
      @controller.request = ActionDispatch::TestRequest.create
      @controller.request.set_header("REMOTE_ADDR", "127.0.0.1")
      @controller.request.set_header("HTTP_USER_AGENT", "development account switch")
    end

    test "development creates a verified request suitable for a normal session" do
      Rails.stub(:env, ActiveSupport::EnvironmentInquirer.new("development")) do
        @controller.send(:ensure_development_env)
        verification_request = @controller.send(:create_verified_request_for, users(:bob))

        assert_predicate verification_request, :persisted?
        assert_predicate verification_request, :verified?
        assert_equal users(:bob).phone_number, verification_request.phone_number
        assert_equal "127.0.0.1", verification_request.ip_address.to_s
        assert_equal "development account switch", verification_request.user_agent
        assert_not verification_request.should_deliver_verification_code?
        assert_predicate Session.new(user: users(:bob), phone_number_verification_request: verification_request), :valid?
      end
    end

    test "development guard is registered as a before action" do
      assert UsersController._process_action_callbacks.any? { |callback|
        callback.kind == :before && callback.filter == :ensure_development_env
      }
    end

    test "development guard rejects test and production" do
      %w[test production].each do |environment|
        Rails.stub(:env, ActiveSupport::EnvironmentInquirer.new(environment)) do
          assert_no_difference -> { PhoneNumberVerificationRequest.count } do
            error = assert_raises(RuntimeError) do
              @controller.send(:ensure_development_env)
            end
            assert_equal "Only available in development", error.message
          end
        end
      end
    end
  end

  class UsersFlowTest < ActionDispatch::IntegrationTest
    test "signed out visitors can see every local account and the seed baseline" do
      with_routes_for("development") do
        get "/admin/users"

        assert_response :success
        User.find_each do |user|
          assert_select "form[action=?][method=post]", "/admin/users/#{user.id}/switch"
          assert_select "dd, [data-slot=item-description]", text: user.phone_number
        end
        assert_select "h2", text: "seed baseline"
        assert_select "img[src*='development-seed-graph']"
        assert_select "a[href='/admin']"
      end
    end

    test "signed out switching creates a verified normal session and redirects home" do
      with_routes_for("development") do
        assert_difference -> { Session.count }, 1 do
          assert_difference -> { PhoneNumberVerificationRequest.count }, 1 do
            post "/admin/users/#{users(:bob).id}/switch"
          end
        end
        assert_response :see_other
        assert_redirected_to home_path
        new_session = signed_in_session

        assert_equal users(:bob), new_session.user
        assert_predicate new_session.phone_number_verification_request, :verified?
        follow_redirect!

        assert_response :success
        assert_equal new_session.id, signed_in_session.id
      end
    end

    test "switching replaces only the current session" do
      sign_in_as(users(:bob))
      current_session = signed_in_session
      other_session = users(:bob).sessions.create!(
        phone_number_verification_request: current_session.phone_number_verification_request,
      )

      with_routes_for("development") do
        assert_no_difference -> { Session.count } do
          post "/admin/users/#{users(:sue).id}/switch"
        end
        assert_not Session.exists?(current_session.id)
        assert Session.exists?(other_session.id)
        follow_redirect!

        assert_equal users(:sue), signed_in_session.user
      end
    end

    test "an unknown user leaves the current session intact" do
      sign_in_as(users(:bob))
      current_session = signed_in_session
      with_routes_for("development") do
        assert_no_difference -> { PhoneNumberVerificationRequest.count } do
          post "/admin/users/#{SecureRandom.uuid}/switch"
        end
        assert_response :not_found
        assert Session.exists?(current_session.id)
      end
    end

    test "routes are absent in test and production" do
      %w[test production].each do |environment|
        with_routes_for(environment) do
          [ [ :get, "/admin/users" ], [ :post, "/admin/users/#{users(:bob).id}/switch" ] ].each do |method, path|
            assert_raises(ActionController::RoutingError) do
              Rails.application.routes.recognize_path(path, method:)
            end
          end
        end
      end
    end

    test "controller rejects both actions outside development even when routes exist" do
      with_routes_for("development") do
        %w[test production].each do |environment|
          with_environment(environment) do
            assert_no_difference -> { Session.count } do
              assert_no_difference -> { PhoneNumberVerificationRequest.count } do
                error = assert_raises(RuntimeError) { get "/admin/users" }
                assert_equal "Only available in development", error.message
                error = assert_raises(RuntimeError) { post "/admin/users/#{users(:bob).id}/switch" }
                assert_equal "Only available in development", error.message
              end
            end
          end
        end
      end
    end

    test "dashboard links to users only in development" do
      sign_in_as(users(:jane))
      with_admins(users(:jane)) do
        get admin_dashboard_path

        assert_select "a[href='/admin/users']", count: 0
        with_routes_for("development") do
          get admin_dashboard_path

          assert_response :success
          assert_select "a[href='/admin/users']", text: "development users"
        end
      end
    end

    private

    def signed_in_session
      cookie_jar = ActionDispatch::TestRequest.create.cookie_jar
      cookie_jar[:session_id] = cookies[:session_id]
      Session.find(cookie_jar.signed[:session_id])
    end

    def with_environment(environment)
      previous_environment = Rails.env
      Rails.env = environment
      yield
    ensure
      Rails.env = previous_environment
    end

    def with_routes_for(environment)
      with_environment(environment) do
        Rails.application.reload_routes!
        yield
      end
    ensure
      Rails.application.reload_routes!
    end
  end
end
