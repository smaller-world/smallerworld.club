# typed: strict
# frozen_string_literal: true

class Components::PhoneNumberInput < Components::Input
  include DeleteFrom

  # == Component ==

  sig { override.void }
  def view_template
    attributes = @attributes
    value = attributes.delete(:value).presence
    input_attributes = delete_from(attributes, :id, :required, :disabled, :placeholder)
    hidden_input_attributes = delete_from(attributes, :name)

    div(**mix(
      {
        class: "phone-number-input",
        data: {
          slot: "phone-number-input",
          controller: "phone-number-input",
        },
      },
      attributes,
    )) do
      Components::Input(value:, **mix(
        {
          data: {
            phone_number_input_target: "input",
            action: [
              "change->phone-number-input#updateHiddenInput",
              "countrychange->phone-number-input#updateHiddenInput",
            ],
          },
        },
        input_attributes,
      ))
      input(type: "hidden", value:, **mix(
        {
          data: {
            phone_number_input_target: "hiddenInput",
          },
        },
        hidden_input_attributes,
      ))
    end
  end
end
