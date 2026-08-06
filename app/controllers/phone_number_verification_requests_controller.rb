# typed: true
# frozen_string_literal: true

class PhoneNumberVerificationRequestsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized
  # rate_limit to: 3,
  #   within: 3.minutes,
  #   only: :create,
  #   with: :handle_rate_limit_exceeded if Rails.env.production?
  before_action :verify_turnstile_request, only: :create
  rate_limit to: 10,
    within: 5.minutes,
    only: :verify,
    by: -> {
      T.bind(self, PhoneNumberVerificationRequestsController)
      params.fetch(:id)
    },
    with: :handle_verify_rate_limit_exceeded if Rails.env.production?

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
        begin
          if verification_request.save
            tag_logger do
              logger.info(
                "Verification code for #{verification_request.phone_number}: " \
                  "#{verification_request.verification_code}",
              )
            end
            actions = [ replace_form(verification_request:) ]
            if verification_request.has_override_code?
              actions << turbo_stream.update(
                "flashes",
                renderable: Components::AppFlashAlert.new(
                  message:
                    "this phone number uses a special login code; you will not receive " \
                    "an sms verification code.",
                ),
              )
            end
            render(turbo_stream: actions)
          elsif (error = verification_request.errors.full_messages_for(:ip_address).first)
            alert = "failed to send verification code: #{error}"
            redirect_to(new_session_path, alert:, status: :see_other)
          else
            actions = [ replace_form(verification_request:) ]
            render(
              turbo_stream: actions,
              status: :unprocessable_content,
            )
          end
        rescue Telnyx::Errors::BadRequestError => error
          tag_logger do
            logger.error("Failed to send verification code: #{error}")
          end
          alert = "failed to send verification code: #{error}"
          redirect_to(new_session_path, alert:, status: :see_other)
        end
      end
    end
  end

  # POST /verifications/:id/verify
  def verify
    respond_to do |format|
      format.turbo_stream do
        verification_request = find_verification_request
        verification_request_params = params
          .expect(phone_number_verification_request: [
            :verification_code,
            phone_number_owner: [ :time_zone_name ],
          ])
        verification_code = verification_request_params.delete(:verification_code)
        begin
          verification_request.verify!(verification_code)
          if (phone_number_owner = verification_request.phone_number_owner)
            phone_number_owner_params = verification_request_params.fetch(:phone_number_owner)
            phone_number_owner.update!(**phone_number_owner_params)
            start_new_session_for(
              phone_number_owner,
              phone_number_verification_request: verification_request,
            )
            redirect_to(after_authentication_url, status: :see_other)
          else
            session[:phone_number_verification_token] =
              verification_request.generate_registration_token
            redirect_to(new_account_path, status: :see_other)
          end
        rescue ActiveRecord::RecordInvalid => error
          render(
            turbo_stream: [
              replace_form(verification_request:),
              turbo_stream.update(
                "flashes",
                renderable: Components::AppFlashAlert.new(
                  type: :alert,
                  message: error.message,
                ),
              ),
            ],
            status: :unprocessable_content,
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

  sig do
    params(verification_request: PhoneNumberVerificationRequest)
      .returns(ActiveSupport::SafeBuffer)
  end
  def replace_form(verification_request:)
    turbo_stream.replace(
      "phone_number_verification_form",
      renderable: Components::PhoneNumberVerificationForm.new(
        verification_request:,
      ),
    )
  end

  # == Callbacks ==

  sig { void }
  def verify_turnstile_request
    if (response = params["cf-turnstile-response"].presence)
      begin
        SmallerWorld.application.turnstile_client.verify(
          response:,
          remoteip: request.remote_ip,
        )
      rescue => error
        redirect_to(
          new_session_path,
          alert: "cloudflare verification failed: #{error.message}",
        )
      end
    else
      redirect_to(
        new_session_path,
        alert: "please click 'verify you are human'!",
      )
    end
  end

  sig { void }
  def handle_rate_limit_exceeded
    redirect_to(
      new_session_path,
      alert: "you have requested a login code too many times. please try again later.",
      status: :see_other,
    )
  end

  sig { void }
  def handle_verify_rate_limit_exceeded
    redirect_to(
      new_session_path,
      alert: "too many incorrect verification attempts. please try again later.",
      status: :see_other,
    )
  end
end
