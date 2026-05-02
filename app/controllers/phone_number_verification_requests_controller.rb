# typed: true
# frozen_string_literal: true

class PhoneNumberVerificationRequestsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  rate_limit to: 3,
    within: 3.minutes,
    only: :create,
    with: :handle_rate_limit_exceeded

  # == Actions ==

  # POST /phone_number_verification_requests
  def create
    respond_to do |format|
      format.html do
        if Rails.env.production?
          redirect_to(
            new_session_path,
            alert:
              "login disabled due to recent attacks on our login systems 😔",
          ) and return
        end

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
          redirect_to([ :verify, verification_request ])
        else
          if (message = verification_request.errors.full_messages_for(:base).first)
            flash.now[:alert] = message
          end
          render Views::Sessions::New.new(verification_request:),
            status: :unprocessable_content
        end
      end
    end
  end

  # GET /phone_number_verification_requests/:id/verify
  def verify
    raise NotImplementedError
  end

  private

  # == Helpers ==

  sig { void }
  def handle_rate_limit_exceeded
    redirect_to(
      new_session_path,
      alert: "you have requested a login code too many times. please try again later.",
    )
  end
end
