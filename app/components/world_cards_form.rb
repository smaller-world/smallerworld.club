# typed: strict
# frozen_string_literal: true

class Components::WorldCardsForm < Components::Base
  # == Initialization ==

  sig do
    params(
      url: String,
      pass_serial_numbers: T::Array[String],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    url:,
    pass_serial_numbers: [],
    **attributes
  )
    @url = url
    @pass_serial_numbers = pass_serial_numbers
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      url: @url,
      method: :put,
      **normalize_mix(
        {
          data: {
            controller: "account-world-cards-form passes-bridge",
            action: "passes-bridge:received->account-world-cards-form#submitPasses",
          },
        },
        @attributes,
      ),
    ) do |form|
      template(data: { world_cards_form_target: "inputTemplate" }) do
        form.hidden_field(:world_card_pass_serial_numbers, multiple: true, value: nil)
      end

      @pass_serial_numbers.each do |value|
        form.hidden_field(
          :world_card_pass_serial_numbers,
          multiple: true,
          value:,
          data: {
            world_cards_form_target: "existingInput",
          },
        )
      end
    end
  end
end
