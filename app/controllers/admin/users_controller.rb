# typed: true
# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    # == Configuration ==

    allow_unauthenticated_access
    skip_verify_authorized
    prepend_before_action :ensure_development_env

    # == Actions ==

    # GET /admin/users
    def index
      users = User.where.not(id: Current.user&.id).order(:name, :phone_number, :id)
      render Views::Admin::Users::Index.new(users:)
    end

    # POST /admin/users/:id/switch
    def switch
      user = User.find(params.fetch(:id))
      Session.transaction do
        verification_request = create_verified_request_for(user)
        terminate_session
        start_new_session_for(user, phone_number_verification_request: verification_request)
      end
      session.delete(:return_to_after_authenticating)
      session.delete(:registration_token)
      redirect_to(home_path, status: :see_other)
    end

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
