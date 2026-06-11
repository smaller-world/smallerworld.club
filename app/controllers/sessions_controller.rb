# typed: true
# frozen_string_literal: true

class SessionsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: [ :new ]
  skip_verify_authorized

  # rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
  #   T.bind(self, SessionsController)
  #   redirect_to(new_session_path, alert: "try again later.")
  # }

  # == Actions ==

  # GET /session/new?pass_serial_numbers[]=...
  def new
    respond_to do |format|
      format.html do
        if authenticated?
          redirect_to(after_authentication_url, notice: "you are already signed in!")
        else
          verification_request = PhoneNumberVerificationRequest.new
          unclaimed_world_cards = if (serial_numbers = params[:pass_serial_numbers])
            WorldCard.kept.unclaimed.with_pass_serial_numbers(serial_numbers)
              .includes(:world)
          end
          render Views::Sessions::New.new(verification_request:, unclaimed_world_cards:)
        end
      end
    end
  end

  # DELETE /session
  def destroy
    terminate_session
    redirect_to(home_path, status: :see_other)
  end
end
