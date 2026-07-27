# typed: strict
# frozen_string_literal: true

class Components::DeviceUpdatePushTokenForm < Components::Base
  # == Initialization ==

  sig { params(current_device: Device, attributes: T.untyped).void }
  def initialize(current_device:, **attributes)
    super(**attributes)
    @current_device = current_device
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @current_device,
      action: device_push_token_path,
      data: {
        controller: "async-submission device-push-token-form",
      },
      hidden: true,
    ) do |form|
      form.Field(:push_token).hidden(data: {
        device_push_token_form_target: "input",
        controller: "notification-permission-bridge notification-token-bridge",
        action: [
          "notification-permission-bridge:authorized->notification-token-bridge#request",
          "notification-token-bridge:retrieved->device-push-token-form#setInputValueAndSubmit",
        ],
      })
    end
  end
end
