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
        if current_user.record_app_visit
          render turbo_stream: append_log_message(
            "Tacked app visit for user: #{current_user.id}",
            level: :info,
          )
        else
          message = "Failed to track app visit for user: #{current_user.id}"
          if (error = current_user.errors.full_messages.first)
            message += " (#{error})"
          end
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
