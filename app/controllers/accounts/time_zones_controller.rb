# typed: true
# frozen_string_literal: true

module Accounts
  class TimeZonesController < ApplicationController
    # == Actions ==

    # PUT /accounts/time_zone
    def update
      respond_to do |format|
        format.turbo_stream do
          user = current_user!
          user_params = params.expect(user: :time_zone_name)
          if user.update(user_params)
            render turbo_stream: append_log_message(
              "User time zone updated",
              level: :info,
            )
          else
            render(
              turbo_stream: append_log_message(
                user.errors.full_messages.first || "Failed to update user",
                level: :error,
              ),
              status: :unprocessable_content,
            )
          end
        end
      end
    end
  end
end
