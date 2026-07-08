# typed: strict
# frozen_string_literal: true

class Components::Checkbox < Components::Input
  include DeleteFrom

  # == Initialization ==

  sig do
    params(
      checked: T::Boolean,
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(checked: false, invalid: false, **attributes)
    super(invalid:, **attributes)
    @checked = checked
  end

  # == Component ==

  sig { override.void }
  def view_template
    attributes = @attributes
    input_attributes = delete_from(attributes, :id, :name, :value, :data)

    span(
      role: "checkbox",
      tabindex: 0,
      **mix(
        {
          class: "checkbox group/checkbox peer",
          data: {
            controller: "checkbox-proxy",
            slot: "checkbox",
            checked: ("" if @checked),
            unchecked: ("" unless @checked),
            action: "click->checkbox-proxy#forwardClick:prevent",
          },
          aria: {
            checked: @checked.to_s,
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
      checked: @checked,
      class: "visually-hidden",
      tabindex: -1,
      aria: {
        hidden: true,
      },
      **input_attributes,
    )
  end
end
