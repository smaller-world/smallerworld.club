# typed: true
# frozen_string_literal: true

# Test-only sign-in backdoor for system tests. Mounted only when
# `Rails.env.test?` in `config/routes.rb`; never reachable in development or
# production. See `docs/testing.md` for usage.
class TestsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized
  before_action :ensure_test_env

  # == Actions ==

  # GET /test/sign_in/:user_id
  def sign_in
    user = User.find(params.fetch(:user_id))
    verification_request = PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: true)
    start_new_session_for(user, phone_number_verification_request: verification_request)
    redirect_to(home_path)
  end

  private

  # == Filters ==

  sig { void }
  def ensure_test_env
    raise "Only available in test environment" unless Rails.env.test?
  end
end
