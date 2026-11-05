# typed: strict
# frozen_string_literal: true

class Components::Checkbox < Components::Input
  include DeleteFrom

  # == Initialization ==

  sig do
    params(
      checked: T::Boolean,
      readonly: T::Boolean,
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(checked: false, readonly: false, invalid: false, **attributes)
    super(invalid:, **attributes)
    @checked = checked
    @readonly = readonly
  end

  # == Component ==

  sig { override.void }
  def view_template
    attributes = @attributes.dup
    input_attributes = delete_from(
      attributes,
      :id, :name, :value, :data, :disabled, :required, :form
    )

    span(
      role: "checkbox",
      tabindex: input_attributes[:disabled] ? -1 : 0,
      **mix(
        {
          class: "checkbox group/checkbox peer",
          data: {
            controller: "checkable-proxy",
            slot: "checkbox",
            checked: ("" if @checked),
            unchecked: ("" unless @checked),
            disabled: ("" if input_attributes[:disabled]),
            readonly: ("" if @readonly),
            action: "click->checkable-proxy#forwardClick:prevent",
          },
          aria: {
            checked: @checked.to_s,
            disabled: ("true" if input_attributes[:disabled]),
            readonly: ("true" if @readonly),
            required: ("true" if input_attributes[:required]),
            invalid: ("true" if @invalid),
          },
        },
        attributes,
      ),
    ) do
      span(
        class: "checkbox-indicator",
        data: {
          slot: "checkbox-indicator",
        },
      ) do
        Icon("huge/tick-02", class: "stroke-2")
      end
    end
    input(
      type: :checkbox,
      tabindex: -1,
      checked: @checked,
      readonly: @readonly,
      class: "visually-hidden",
      aria: {
        hidden: "true",
      },
      **input_attributes,
    )
  end
end
