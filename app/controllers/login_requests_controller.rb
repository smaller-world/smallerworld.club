# typed: true
# frozen_string_literal: true

class LoginRequestsController < ApplicationController
  # == Filters ==

  before_action :require_stored_login_request!, only: :complete
  rate_limit to: 10,
             within: 3.minutes,
             only: :create,
             with: :handle_rate_limit_exceeded

  # == Actions ==

  # POST /login_requests
  def create
    login_request_params = params.expect(
      login_request: [ :phone_number ],
    )
    @login_request = LoginRequest.create(**login_request_params)
    tag_logger do
      logger.info(
        "Sending login code #{@login_request.login_code} to " \
          "#{@login_request.phone_number}",
      )
    end
    respond_to do |format|
      format.json do
        if @login_request.persisted?
          data = if Rails.env.production?
            {}
          else
            { "loginRequest" => LoginRequestSerializer.one(@login_request) }
          end
          render(json: data, status: :created)
        else
          render(
            json: {
              errors: @login_request.form_errors,
            },
            status: :unprocessable_content,
          )
        end
      end
      format.html do
        session[:login_request_id] = @login_request.id
        redirect_to(complete_login_request_path)
      end
    end
  end

  # GET /login/enter_code
  def complete
    respond_to do |format|
      format.html do
        @page_title = "check your phone"
        @login_request = stored_login_request
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(LoginRequest) }
  def stored_login_request
    LoginRequest.find(session.fetch(:login_request_id))
  end


  # == Filter handlers ==

  sig { void }
  def require_stored_login_request!
    unless session.include?(:login_request_id)
      redirect_to(new_session_path)
    end
  end

  sig { void }
  def handle_rate_limit_exceeded
    error = "You have requested a login code too many times. Please try " \
      "again later."
    render(json: { error: }, status: :too_many_requests)
  end
end
