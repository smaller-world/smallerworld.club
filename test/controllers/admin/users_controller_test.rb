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
end
