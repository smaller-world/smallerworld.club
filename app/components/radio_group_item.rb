# typed: strict
# frozen_string_literal: true

class Components::RadioGroupItem < Components::Input
  include DeleteFrom

  # == Initialization ==

  sig do
    params(
      value: T.nilable(T.any(String, T::Boolean)),
      checked: T::Boolean,
      invalid: T::Boolean,
      toggleable: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(value: nil, checked: false, invalid: false, toggleable: false, **attributes)
    super(invalid:, **attributes)
    @value = value
    @checked = checked
    @toggleable = toggleable
  end

  # == Component ==

  sig { override.void }
  def view_template
    attributes = @attributes
    input_attributes = delete_from(attributes, :id, :name, :data)

    span(
      role: "radio",
      tabindex: 0,
      **mix(
        {
          class: "radio-group-item group/radio-group-item peer",
          data: {
            controller: token_list("checkbox-proxy", "radio-toggle" => @toggleable),
            slot: "radio-group-item",
            checked: ("" if @checked),
            unchecked: ("" unless @checked),
            action: @toggleable ? "click->radio-toggle#toggle" : "click->checkbox-proxy#forwardClick",
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
        class: "radio-group-indicator",
        data: {
          slot: "radio-group-indicator",
        },
      ) do
        span
      end
    end
    input(
      type: :radio,
      value:,
      tabindex: -1,
      class: "visually-hidden",
      aria: {
        hidden: true,
      },
      **mix(
        {
          data: {
            controller: "radio-group-item",
            action: "change->radio-group-item#updateOtherItems",
          },
        },
        input_attributes,
      ),
    )
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def value
    case @value
    when true
      "1"
    when false
      "0"
    else
      @value
    end
  end
end
