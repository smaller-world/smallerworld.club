# typed: strict
# frozen_string_literal: true

class Components::DevicePushTokenForm < Components::Base
  # == Initialization ==

  sig { params(current_device: Device, attributes: T.untyped).void }
  def initialize(current_device:, **attributes)
    @current_device = current_device
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @current_device,
      action: device_push_token_path,
      data: {
        controller: "submit",
      },
      hidden: true,
    ) do |form|
      form.Field(:push_token).hidden(
        data: {
          controller: "connection notification-token-bridge device-push-token-input",
          notification_token_bridge_provisional_value: true,
          action: token_list(
            "connection:connect->notification-token-bridge#request",
            "notification-token-bridge:retrieved->device-push-token-input#setValue",
            "device-push-token-input:changed->submit#request",
          ),
        },
      )
    end
  end
end
