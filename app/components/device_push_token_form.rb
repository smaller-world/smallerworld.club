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
    form_with(
      model: @current_device,
      url: device_push_token_path,
      data: {
        controller: "submit",
      },
      html: {
        hidden: true,
      },
    ) do |form|
      form.hidden_field(
        :push_token,
        data: {
          controller: "connection notification-token-bridge push-token-input",
          notification_token_bridge_provisional_value: true,
          action: token_list(
            "connection:connect->notification-token-bridge#request",
            "notification-token-bridge:retrieved->push-token-input#setValue",
            "push-token-input:changed->submit#request",
          ),
        },
      )
    end
  end
end
