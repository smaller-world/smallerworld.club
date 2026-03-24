# typed: true
# frozen_string_literal: true

class PasswordsController < ApplicationController
  # == Filters ==

  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    T.bind(self, PasswordsController)
    redirect_to(new_password_path, alert: "Try again later.")
  }

  # == Actions ==

  # GET /passwords/new
  def new
    respond_to do |format|
      format.html do
        render Views::Passwords::New.new(
          email_address: params[:email_address],
        )
      end
    end
  end

  # GET /passwords/:token/edit
  def edit
    respond_to do |format|
      format.html do
        with_user_by_token do |user|
          render Views::Passwords::Edit.new(user:, token: params[:token])
        end
      end
    end
  end

  # POST /passwords
  def create
    respond_to do |format|
      format.html do
        if (user = User.find_by(email_address: params[:email_address]))
          PasswordsMailer.reset(user).deliver_later
        end
        redirect_to(new_session_path, notice: "password reset email sent!")
      end
    end
  end

  # PUT/PATCH /passwords/:token
  def update
    respond_to do |format|
      format.html do
        with_user_by_token do |user|
          if user.update(params.permit(:password, :password_confirmation))
            user.sessions.destroy_all
            redirect_to(new_session_path, notice: "password has been reset.")
          else
            redirect_to(
              edit_password_path(params[:token]),
              alert: "passwords did not match.",
            )
          end
        end
      end
    end
  end

  private

  sig { params(block: T.proc.params(user: User).void).void }
  def with_user_by_token(&block)
    user = User.find_by_password_reset_token!(params[:token])
    yield user
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to(new_password_path, alert: "Password reset link is invalid or has expired.")
  end
end
