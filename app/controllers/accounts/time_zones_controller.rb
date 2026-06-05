# typed: true
# frozen_string_literal: true

module Accounts
  class TimeZonesController < ApplicationController
    # == Configuration ==

    skip_verify_authorized

    # == Actions ==

    # PUT /accounts/time_zone
    def update
      respond_to do |format|
        format.turbo_stream do
          current_user = Current.user!
          user_params = params.expect(user: :time_zone_name)
          if current_user.update(user_params)
            render turbo_stream: append_log_message(
              "User time zone updated",
              level: :info,
            )
          else
            message = "Failed to update user timezone"
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
end
