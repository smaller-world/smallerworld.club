# typed: true
# frozen_string_literal: true

class AccountEmailAddressConfirmationsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: [ :show, :create ]
  skip_verify_authorized
  rate_limit to: 5,
    within: 3.minutes,
    only: :resend,
    with: :handle_rate_limit_exceeded if Rails.env.production?

  # == Actions ==

  # GET /account/email_address_confirmation?confirmation_token=...
  #
  # Renders an auto-submitting form that POSTs back to `create`. Requiring
  # client-side interactivity to confirm prevents email link scanners and
  # prefetchers from silently confirming via a plain GET.
  def show
    respond_to do |format|
      format.html do
        user = User.find_by_email_address_confirmation_token!(confirmation_token)
        if (current_user = Current.user) && current_user != user
          terminate_session
        end
        render Views::AccountEmailAddressConfirmations::Show.new(
          confirmation_token:,
        )
      rescue ActiveRecord::RecordNotFound
        redirect_to(root_path, alert: bad_confirmation_token_alert)
      end
    end
  end

  # POST /account/email_address_confirmation
  def create
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
        redirect_to(root_path, alert: bad_confirmation_token_alert)
      end
    end
  end

  # GET /account/email_address_confirmation/resend
  def resend
    respond_to do |format|
      format.html do
        user = Current.user!
        user.deliver_email_address_confirmation_later
        redirect_to(
          edit_account_path,
          status: :see_other,
          notice: "we sent you another email to confirm your email address",
        )
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def confirmation_token
    @confirmation_token ||= T.let(params.require(:confirmation_token), T.nilable(String))
  end

  sig { returns(String) }
  def bad_confirmation_token_alert
    "this confirmation link is invalid or expired. please request another " \
      "one from your account settings page!"
  end

  # == Callbacks ==

  sig { void }
  def handle_rate_limit_exceeded
    redirect_to(
      edit_account_path,
      status: :see_other,
      alert: "you're doing that too much. please try again in a few minutes.",
    )
  end
end
