# typed: strict
# frozen_string_literal: true

class Components::Checkbox < Components::Input
  include Phlex::Rails::Helpers::CheckboxTag

  # == Initialization ==

  sig do
    params(
      value: String,
      checked: T.nilable(T::Boolean),
      multiple: T::Boolean,
      disabled: T::Boolean,
      input: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    value: "on",
    checked: nil,
    multiple: false,
    disabled: false,
    input: {},
    **attributes
  )
    super(**attributes)
    @value = value
    @checked = checked
    @multiple = multiple
    @disabled = disabled
    @input_options = input
  end

  # == Component ==

  sig { override.void }
  def view_template
    root_element(
      :span,
      class: "checkbox group/checkbox peer",
      role: "checkbox",
      tabindex: 0,
      data: {
        controller: "checkbox",
        slot: "checkbox",
        checked: ("" if checked?),
        unchecked: ("" unless checked?),
        action: "click->checkbox#forwardClick:prevent",
      },
      aria: {
        checked: !!checked?,
      },
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
    if @form
      @form.checkbox(@field, input_options, @value, @multiple ? nil : "off")
    else
      checkbox_tag(@field, input_options, @value, @multiple ? nil : "off")
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def checked?
    return @checked unless @checked.nil?
    return false unless (object = @form&.object) && @field

    case (value = object.try(@field))
    when true, false
      value
    when nil
      false
    when Array
      value.map(&:to_s).include?(@value.to_s)
    else
      value.to_s == @value.to_s
    end
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def input_options
    normalize_mix(
      {
        checked: checked?,
        tabindex: -1,
        multiple: @multiple,
        disabled: @disabled,
        aria: {
          hidden: true,
        },
      },
      @input_options,
    )
  end
end
