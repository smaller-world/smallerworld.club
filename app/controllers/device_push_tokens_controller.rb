# typed: true
# frozen_string_literal: true

class DevicePushTokensController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized

  # == Actions ==

  # POST /device/push_tokens/test
  def test
    respond_to do |format|
      format.turbo_stream do
        current_device = Current.device!
        current_device.send_test_notification
        render turbo_stream: append_toast("test notification sent!", type: :success)
      end
    end
  end

  # PUT/PATCH /device/push_token
  def update
    respond_to do |format|
      format.turbo_stream do
        current_device = Current.device!
        device_params = params.expect(device: [ :push_token ])
        if current_device.update(device_params)
          render turbo_stream: [
            append_log_message("Device push token updated", level: :info),
            turbo_stream.refresh,
          ]
        else
          message = "Failed to update device push token"
          if (error = current_device.errors.full_messages.first)
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
