# typed: true
# frozen_string_literal: true

class SessionsController < ApplicationController
  # == Filters ==

  allow_unauthenticated_access only: [ :new ]

  # rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
  #   T.bind(self, SessionsController)
  #   redirect_to(new_session_path, alert: "try again later.")
  # }

  # == Actions ==

  # GET /sessions/new
  def new
    respond_to do |format|
      format.html do
        if authenticated?
          redirect_to(
            after_authentication_url,
            notice: "you are already signed in!",
          )
        else
          render Views::Sessions::New.new
        end
      end
    end
  end

  # POST /sessions/apple_oauth
  def apple_oauth
    appleid_signin_state = SecureRandom.hex(16)
    appleid_signin_nonce = SecureRandom.hex(16)
    session[:appleid_signin_state] = appleid_signin_state
    session[:appleid_signin_nonce] = appleid_signin_nonce
    # authorization_url =
  end

  # DELETE /sessions
  def destroy
    terminate_session
    redirect_to(new_session_path, status: :see_other)
  end
end
