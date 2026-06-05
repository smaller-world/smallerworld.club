# typed: strict
# frozen_string_literal: true

class Components::DeviceWorldCardsForm < Components::Base
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
      url: device_world_cards_path,
      method: :put,
      hidden: true,
      **normalize_mix(
        {
          data: {
            controller: "device-world-cards-form passes-bridge",
            action: "passes-bridge:received->device-world-cards-form#submitPasses",
          },
        },
        @attributes,
      ),
    ) do |form|
      template(data: { device_world_cards_form_target: "inputTemplate" }) do
        form.hidden_field(
          :world_card_pass_serial_numbers,
          multiple: true,
          value: nil,
          data: {
            device_world_cards_form_target: "addedInput",
          },
        )
      end

      @current_device.world_card_passes.pluck(:serial_number).each do |value|
        form.hidden_field(
          :world_card_pass_serial_numbers,
          multiple: true,
          value:,
          data: {
            device_world_cards_form_target: "existingInput",
          },
        )
      end
    end
  end
end
