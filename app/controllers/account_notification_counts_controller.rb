# typed: true
# frozen_string_literal: true

class AccountNotificationCountsController < ApplicationController
  # == Configuration ==

  skip_verify_authorized

  # == Actions ==

  # POST /accounts/notification_count/clear
  def clear
    respond_to do |format|
      format.turbo_stream do
        current_user = Current.user!
        if current_user.clear_notifications
          render turbo_stream: append_log_message(
            "User notification count cleared",
            level: :info,
          )
        else
          message = "Failed to clear notification count"
          if (error = current_user.errors.full_messages.first)
            message = "#{message}: #{error}"
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
