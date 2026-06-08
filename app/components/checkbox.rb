# typed: strict
# frozen_string_literal: true

class Components::Checkbox < Components::Input
  include Phlex::Rails::Helpers::CheckboxTag

  # == Initialization ==

  sig do
    params(
      value: T.any(Symbol, String, Enumerize::Value),
      checked: T.nilable(T::Boolean),
      multiple: T::Boolean,
      input: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    value: "1",
    checked: nil,
    multiple: false,
    input: {},
    **attributes
  )
    super(**attributes)
    @value = value
    @checked = checked
    @multiple = multiple
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
        action: "click->checkbox#forwardClick",
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
      @form.checkbox(@field, input_options, @value, @multiple ? nil : "0")
    else
      checkbox_tag(@field, input_options, @value, @multiple ? nil : "0")
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def checked?
    if @checked.nil?
      if (object = @form&.object) && @field
        !!object.public_send(@field)
      else
        false
      end
    else
      @checked
    end
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def input_options
    normalize_mix(
      {
        checked: checked?,
        tabindex: -1,
        multiple: @multiple,
        aria: {
          hidden: true,
        },
      },
      @input_options,
    )
  end
end
