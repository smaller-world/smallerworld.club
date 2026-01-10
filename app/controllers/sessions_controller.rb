# typed: true
# frozen_string_literal: true

class SessionsController < ApplicationController
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
          @login_request = LoginRequest.new
        end
      end
    end
  end

  # POST /login
  def create
    login_request_params = params.expect(
      login_request: %i[phone_number login_code],
    )
    @login_request = LoginRequest.find_valid(
      **login_request_params.to_h.symbolize_keys,
    )
    respond_to do |format|
      format.html do
        if @login_request
          if (user = User.find_by_phone_number(@login_request.phone_number))
            start_new_session_for!(user)
            redirect_to(after_authentication_path)
          else
            self.registration_token = @login_request.generate_registration_token
            redirect_to(new_registration_path)
          end
          @login_request.mark_as_completed!
        else
          @login_request = LoginRequest.new
          render(:new, status: :unprocessable_content)
        end
      end
    end
  end

  # POST /logout
  def destroy
    respond_to do |format|
      format.html do
        terminate_session!
        redirect_to(root_path)
      end
      format.json do
        terminate_session!
        render(json: {})
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def after_authentication_path
    session.fetch(:return_to_after_authenticating) do
      if hotwire_native_app?
        spaces_path
      else
        user_world_path
      end
    end
  end
end
