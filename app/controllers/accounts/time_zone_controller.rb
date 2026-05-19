# typed: true
# frozen_string_literal: true

module Accounts
  class TimeZoneController < ApplicationController
    # PUT/PATCH /accounts/time_zone
    def update_time_zone
      user = current_user!
      user_params = params.expect(user: :time_zone_name)
      if user.update(user_params)
        render(status: :ok)
      else
        render(
          json: {
            error: user.errors.full_messages.first || "Failed to update user",
          },
          status: :unprocessable_content,
        )
      end
    end
  end
end
