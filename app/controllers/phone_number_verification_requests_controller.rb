# typed: true
# frozen_string_literal: true

class PhoneNumberVerificationRequestsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized
  rate_limit to: 3,
    within: 3.minutes,
    only: :create,
    with: :handle_rate_limit_exceeded if Rails.env.production?
  before_action :verify_turnstile_request, only: :create

  # == Actions ==

  # POST /verifications
  def create
    respond_to do |format|
      format.turbo_stream do
        verification_request_params = params.expect(
          phone_number_verification_request: [ :phone_number ],
        )
        verification_request = PhoneNumberVerificationRequest.new(
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
          **verification_request_params,
        )
        if verification_request.save
          tag_logger do
            logger.info(
              "Verification code for #{verification_request.phone_number}: " \
                "#{verification_request.verification_code}",
            )
          end
          render turbo_stream: turbo_stream.replace(
            :login_form,
            renderable: Components::PhoneNumberVerificationRequestForm
              .new(verification_request:),
          )
        elsif (message = verification_request.errors.full_messages_for(:ip_address).first)
          redirect_to(new_session_path, alert: message)
        else
          render turbo_stream: turbo_stream.replace(
            :login_form,
            renderable: Components::PhoneNumberVerificationRequestForm
              .new(verification_request:),
          )
        end
      end
    end
  end

  # POST /verifications/:id/verify
  def verify
    respond_to do |format|
      format.html do
        verification_request = find_verification_request
        verification_code = params
          .require(:phone_number_verification_request)
          .fetch(:verification_code)
        if verification_request.verify(verification_code)
          user = User.find_by(phone_number: verification_request.phone_number)
          if user
            time_zone_name = params.require(:user).fetch(:time_zone_name)
            user.update!(time_zone_name:)
            start_new_session_for(
              user,
              phone_number_verification_request: verification_request,
            )
            redirect_to(after_authentication_url)
          else
            session[:phone_number_verification_token] =
              verification_request.generate_registration_token
            redirect_to(new_account_path)
          end
        else
          redirect_to(
            [ :challenge, verification_request ],
            alert: "invalid verification code. please try again.",
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(PhoneNumberVerificationRequest) }
  def find_verification_request
    PhoneNumberVerificationRequest.find(params.fetch(:id))
  end

  sig { void }
  def handle_rate_limit_exceeded
    redirect_to(
      new_session_path,
      alert: "you have requested a login code too many times. please try again later.",
    )
  end

  sig { void }
  def verify_turnstile_request
    if (response = params["cf-turnstile-response"])
      begin
        Smallerworld.application.turnstile_client.verify(
          response:,
          remoteip: request.remote_ip,
        )
      rescue => error
        redirect_to(new_session_path, alert: "Cloudflare verification failed: #{error.message}")
      end
    else
      redirect_to(new_session_path, alert: "please verify you are human!")
    end
  end
end
