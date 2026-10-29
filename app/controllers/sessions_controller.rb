# typed: true
# frozen_string_literal: true

class SessionsController < ApplicationController
  # == Configuration ==

  require_unauthenticated_access only: :new
  skip_verify_authorized

  # == Actions ==

  # GET /session/new[?phone_number=...][&redirect_to=...]
  def new
    respond_to do |format|
      format.html do
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

  # DELETE /session
  def destroy
    terminate_session
    session.delete(:registration_token)
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
      new_session_path
    else
      root_path
    end
  end
end
