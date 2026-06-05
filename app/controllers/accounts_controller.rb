# typed: true
# frozen_string_literal: true

class AccountsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized

  # == Actions ==

  # GET /account/new
  def new
    respond_to do |format|
      format.html do
        phone_number_verification_token = session[:phone_number_verification_token]
        unless phone_number_verification_token
          tag_logger do
            logger.warn("Missing phone number verification token")
          end
          redirect_to(new_session_path)
          return
        end

        verification_request = PhoneNumberVerificationRequest
          .find_by_registration_token(phone_number_verification_token)
        unless verification_request&.verified?
          tag_logger do
            logger.warn("Invalid phone number verification token")
          end
          redirect_to(new_session_path)
          return
        end

        user = User.new
        render Views::Accounts::New.new(user:)
      end
    end
  end

  # POST /account
  def create
    respond_to do |format|
      format.html do
        user_params = params.expect(user: [ :name, :time_zone_name ])
        phone_number_verification_token = session[:phone_number_verification_token]
        unless phone_number_verification_token
          tag_logger do
            logger.warn("Missing phone number verification token")
          end
          redirect_to(
            new_session_path,
            alert: "Missing phone number verification token",
          )
          return
        end

        phone_number_verification_request = PhoneNumberVerificationRequest
          .find_by_registration_token(phone_number_verification_token)
        unless phone_number_verification_request
          tag_logger do
            logger.warn("Invalid phone number verification token")
          end
          redirect_to(
            new_session_path,
            alert: "Invalid phone number verification token",
          )
          return
        end

        user = User.new(
          **user_params,
          phone_number: phone_number_verification_request.phone_number,
        )
        if user.save
          session.delete(:phone_number_verification_token)
          start_new_session_for(user, phone_number_verification_request:)
          redirect_to(after_authentication_url)
        else
          render Views::Accounts::New.new(user:), status: :unprocessable_content
        end
      end
    end
  end
end
