# typed: true
# frozen_string_literal: true

class SessionsController < ApplicationController
  # == Filters ==

  before_action :require_login_request!, only: :create

  # == Actions ==

  # GET /login
  def new
    respond_to do |format|
      format.html do
        if signed_in?
          redirect_to(
            user_world_path(params.permit(:pwa_scope)),
            notice: "you are already signed in :)",
          )
        else
          if (redirect_url = params[:redirect_to])
            session[:return_to_after_authenticating] = redirect_url
          end
          @page_title = "enter your phone #" unless hotwire_native_app?
          @login_request = LoginRequest.new
        end
      end
    end
  end

  # POST /login
  def create
    respond_to do |format|
      format.html do
        @login_request = stored_login_request
        login_code = params.dig(:login_request, :login_code)
        if @login_request.expired?
          redirect_to(
            new_session_path,
            status: :see_other,
            alert: "login code expired; please try again.",
          ) and return
        end
        if @login_request.authenticate(login_code)
          session.delete(:login_request_id)
          if (user = User.find_by_phone_number(@login_request.phone_number))
            start_new_session_for!(user)
            redirect_to(after_authentication_path, status: :see_other)
          else
            self.registration_token = @login_request.generate_registration_token
            redirect_to(new_registration_path, status: :see_other)
          end
        else
          render "login_requests/complete", status: :unprocessable_content
        end
      end
    end
  end

  # POST /logout
  def destroy
    respond_to do |format|
      format.html do
        terminate_session!
        if hotwire_native_app?
          refresh_or_redirect_to(app_start_path)
        else
          redirect_to(root_path)
        end
      end
      format.json do
        terminate_session!
        render(json: {})
      end
    end
  end

  private

  # == Filter handlers ==

  sig { void }
  def require_login_request!
    unless session.include?(:login_request_id)
      redirect_to(
        new_session_path,
        status: :see_other,
        alert: "login attempt failed; please try again.",
      )
    end
  end

  # == Helpers ==

  sig { returns(LoginRequest) }
  def stored_login_request
    LoginRequest.find(session.fetch(:login_request_id))
  end

  sig { returns(String) }
  def after_authentication_path
    session.delete(:return_to_after_authenticating) ||
      default_after_authentication_path
  end

  sig { returns(String) }
  def default_after_authentication_path
    if hotwire_native_app?
      app_start_path
    else
      web_start_path
    end
  end
end
