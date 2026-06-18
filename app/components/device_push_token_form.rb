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
      data: { controller: "form" },
      html: { hidden: true },
    ) do |form|
      form.hidden_field(
        :push_token,
        data: {
          controller: "notification-token-bridge push-token-input",
          notification_token_bridge_provisional_value: true,
          action: token_list(
            "push-token-input:connected->notification-token-bridge#request",
            "notification-token-bridge:retrieved->push-token-input#setToken",
            "push-token-input:token-set->form#requestSubmit",
          ),
        },
      )
    end
  end
end
