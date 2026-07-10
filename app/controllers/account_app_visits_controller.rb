# typed: true
# frozen_string_literal: true

class AccountAppVisitsController < ApplicationController
  # == Configuration ==

  skip_verify_authorized

  # == Actions ==

  # POST /account/app_visits
  def create
    respond_to do |format|
      format.turbo_stream do
        current_user = Current.user!
        begin
          current_user.record_app_visit!
          render turbo_stream: append_log_message(
            "Recorded app visit for user: #{current_user.id}",
            level: :info,
          )
        rescue => error
          message =
            "Failed to track app visit for user: #{current_user.id} (#{error.message})"
          Sentry.capture_message(message)
          render(
            turbo_stream: append_log_message(message, level: :error),
            status: :unprocessable_content,
          )
        end
      end
    end
  end
end
