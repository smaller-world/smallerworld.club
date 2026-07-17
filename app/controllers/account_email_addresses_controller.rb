# typed: true
# frozen_string_literal: true

class AccountEmailAddressesController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized

  # == Actions ==

  # GET /account/email_address/confirm?token=...
  def confirm
    respond_to do |format|
      format.html do
        user = User.find_by_email_address_confirmation_token!(confirmation_token)
        user.confirm_email_address!
        notice = "your email address has been confirmed. thanks!"
        if authenticated?
          redirect_to(home_path, notice:)
        else
          redirect_to(root_path, notice:)
        end
      rescue ActiveRecord::RecordNotFound
        redirect_to(
          root_path,
          alert: "failed to confirm email address: invalid confirmation token",
        )
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def confirmation_token
    @confirmation_token ||= T.let(params.fetch(:token), T.nilable(String))
  end
end
