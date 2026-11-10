# typed: true
# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    # == Configuration ==

    before_action :ensure_development_env

    private

    # == Helpers ==

    sig { params(user: User).returns(PhoneNumberVerificationRequest) }
    def create_verified_request_for(user)
      PhoneNumberVerificationRequest.create!(
        phone_number: user.phone_number,
        ip_address: request.remote_ip,
        user_agent: request.user_agent.to_s,
        verified_at: Time.current,
      )
    end

    # == Filters ==

    sig { void }
    def ensure_development_env
      raise "Only available in development" unless Rails.env.development?
    end
  end
end
