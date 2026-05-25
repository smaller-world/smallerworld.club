# typed: true
# frozen_string_literal: true

class SessionsController < ApplicationController
  # == Configuration ==

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
          verification_request = PhoneNumberVerificationRequest.new
          render Views::Sessions::New.new(verification_request:)
        end
      end
    end
  end

  # POST /sessions
  def create
    # verification_request_params = params.expect(phone_number_verification_request: [
    #   :phone_number,
    #   :code,
    # ])
    # user_id = params.expect(:user_id)
    # user = User.find(user_id)
    # start_new_session_for(user)
    # redirect_to(after_authentication_url)
  end

  # DELETE /sessions
  def destroy
    terminate_session
    redirect_to(new_session_path, status: :see_other)
  end
end
