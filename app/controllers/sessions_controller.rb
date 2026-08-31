# typed: true
# frozen_string_literal: true

class SessionsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: :new
  skip_verify_authorized

  # == Actions ==

  # GET /session/new[?phone_number=...][&redirect_to=...]
  def new
    respond_to do |format|
      format.html do
        if authenticated?
          redirect_to(after_authentication_url, notice: "you are already signed in!")
        else
          if (redirect_to = params[:redirect_to])
            session[:return_to_after_authenticating] = redirect_to
          end
          phone_number = if (phone_number = params[:phone_number])
            PhoneNumberVerificationRequest
              .normalize_value_for(:phone_number, phone_number)
          end
          verification_request = PhoneNumberVerificationRequest.new(phone_number:)
          render Views::Sessions::New.new(verification_request:)
        end
      end
    end
  end

  # DELETE /session
  def destroy
    terminate_session
    redirect_to(
      after_sign_out_url,
      notice: "bye! see ya next time.",
      status: :see_other,
    )
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def after_sign_out_url
    if hotwire_native_app?
      start_path
    else
      root_path
    end
  end
end
