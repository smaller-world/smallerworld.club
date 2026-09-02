# typed: true
# frozen_string_literal: true

class AccountsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: [ :new, :create ]
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
          redirect_url = if authenticated?
            home_path
          else
            new_session_path
          end
          redirect_to(redirect_url) and return
        end

        verification_request = PhoneNumberVerificationRequest
          .find_by_registration_token(phone_number_verification_token)
        unless verification_request&.verified?
          tag_logger do
            logger.warn("Invalid phone number verification token")
          end
          redirect_to(new_session_path) and return
        end

        user = User.new
        render Views::Accounts::New.new(user:)
      end
    end
  end

  # GET /account/edit
  def edit
    respond_to do |format|
      format.html do
        current_user = Current.user!
        render Views::Accounts::Edit.new(current_user:)
      end
    end
  end

  # POST /account
  def create
    respond_to do |format|
      format.html do
        user_params = params.expect(user: [ :name, :unconfirmed_email_address, :time_zone_name ])
        phone_number_verification_token = session[:phone_number_verification_token]
        unless phone_number_verification_token
          tag_logger do
            logger.warn("Missing phone number verification token")
          end
          redirect_to(
            new_session_path,
            alert: "Missing phone number verification token",
            status: :see_other,
          )
          return
        end

        phone_number_verification_request = PhoneNumberVerificationRequest
          .find_by_registration_token(phone_number_verification_token)
        unless phone_number_verification_request&.verified?
          tag_logger do
            logger.warn("Invalid phone number verification token")
          end
          redirect_to(
            new_session_path,
            alert: "Invalid phone number verification token",
            status: :see_other,
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
          redirect_to(after_authentication_url, status: :see_other)
        else
          render Views::Accounts::New.new(user:), status: :unprocessable_content
        end
      end
    end
  end

  # PUT/PATCH /account
  def update
    respond_to do |format|
      format.html do
        current_user = Current.user!
        user_params = params.expect(user: [
          :name,
          :time_zone_name,
          :unconfirmed_email_address,
        ])
        if current_user.update(user_params)
          alert = if current_user.unconfirmed_email_address? &&
              current_user.saved_change_to_unconfirmed_email_address?
            "please check your inbox for a confirmation email! ty <3"
          end
          refresh_or_redirect_to(
            home_path,
            status: :see_other,
            notice: "your account settings were saved",
            alert:,
          )
        else
          render Views::Accounts::Edit.new(current_user:), status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /account
  def destroy
    respond_to do |format|
      format.html do
        current_user = Current.user!
        if current_user.destroy
          redirect_to(root_path, notice: "your account has been deleted. bye-bye!")
        else
          render Views::Accounts::Edit.new(current_user:), status: :unprocessable_content
        end
      end
    end
  end
end
