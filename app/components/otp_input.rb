# typed: true
# frozen_string_literal: true

# OTP input component for verification codes.
# Maps to shadcn's input-otp component.
class Components::OtpInput < Components::Input
  # == Configuration ==

  PATTERN_PRESETS = {
    digits: "\\d",
    chars: "[a-zA-Z]",
    alphanumeric: "[a-zA-Z0-9]",
  }.freeze

  # == Initialization ==

  sig do
    params(
      max_length: Integer,
      pattern: T.any(Symbol, String),
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      input: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    max_length: 6,
    pattern: :digits,
    form: nil,
    field: nil,
    input: {},
    **attributes
  )
    @max_length = max_length
    @pattern = T.let(
      case pattern
      when Symbol
        PATTERN_PRESETS.fetch(pattern) do
          raise InvalidParameter.new(parameter: :pattern, value: pattern)
        end
      else
        pattern
      end,
      String,
    )
    @input_options = input
    super(form:, field:, **attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    input_options = mix(
      {
        maxlength: @max_length,
        autocomplete: "one-time-code",
        inputmode: "numeric",
        spellcheck: false,
        data: {
          otp_input_target: "input",
          action: [
            "otp-input#processInput",
            "focus->otp-input#updateSlots",
            "blur->otp-input#updateSlots",
            "keydown->otp-input#filterKey",
            "keyup->otp-input#handleSelectionChange",
            "click->otp-input#handleSelectionChange",
            "paste->otp-input#processInput",
          ],
        },
      },
      @input_options,
    )

    root_element(
      :div,
      class: "otp-input group/otp-input",
      data: {
        slot: "otp-input",
        controller: "otp-input",
        otp_input_max_length_value: @max_length,
        otp_input_pattern_value: @pattern,
      },
    ) do
      if @form && @field
        @form.text_field(@field, **normalize_attributes(input_options))
      else
        input(type: :text, **input_options)
      end
      div(class: "otp-input-group", data: { slot: "otp-input-group" }) do
        @max_length.times do |index|
          div(
            class: "otp-input-slot",
            data: {
              slot: "otp-input-slot",
              otp_input_target: "slot",
              otp_input_index: index,
              action: "click->otp-input#handleSlotClick",
            },
          )
        end
      end

      template(data: { otp_input_target: "caretTemplate" }) do
        div(class: "otp-input-caret") do
          div
        end
      end
    end
  end
end
