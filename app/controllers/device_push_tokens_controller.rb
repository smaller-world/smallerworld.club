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
        world = if (world_id = params[:world_id])
          world = World.find(world_id)
          world if allowed_to?(:show?, world)
        end
        begin
          current_device.send_test_notification(world:)
          render turbo_stream: append_toast("test notification sent!", type: :success)
        rescue => error
          render turbo_stream: append_toast(
            "failed to send notification: #{error.message}",
            type: :error,
          )
        end
      end
    end
  end

  # PUT/PATCH /device/push_token
  def update
    respond_to do |format|
      format.html do
        current_device = Current.device!
        device_params = params.expect(device: [ :push_token ])
        if current_device.update(device_params)
          redirect_back_or_to(home_path, notice: "push notifications enabled <3")
        else
          message = "Failed to update device push token"
          if (error = current_device.errors.full_messages.first)
            message = "#{message}: #{error}"
          end
          Sentry.capture_message(message)
          redirect_back_or_to(home_path, alert: message)
        end
      end
    end
  end
end
