# typed: true
# frozen_string_literal: true

class SessionsController < ApplicationController
  # == Filters ==

  allow_unauthenticated_access only: [ :new, :create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    T.bind(self, SessionsController)
    redirect_to(new_session_path, alert: "try again later.")
  }

  # == Actions ==

  def new
    respond_to do |format|
      format.html do
        if authenticated?
          redirect_to(
            after_authentication_url,
            notice: "you are already signed in!",
          )
        else
          render Views::Sessions::New
        end
      end
    end
  end

  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password)))
      start_new_session_for(user)
      redirect_to(after_authentication_url)
    else
      redirect_to(
        new_session_path,
        alert: "try another email address or password.",
      )
    end
  end

  def destroy
    terminate_session
    redirect_to(new_session_path, status: :see_other)
  end
end
