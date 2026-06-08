# typed: strict
# frozen_string_literal: true

class Components::RadioGroup::Item < Components::Input
  include Phlex::Rails::Helpers::RadioButtonTag

  # == Initialization ==

  sig do
    params(
      radio_group: Components::RadioGroup,
      value: T.any(Symbol, String, Enumerize::Value),
      checked: T.nilable(T::Boolean),
      input: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    radio_group:,
    value:,
    checked: nil,
    input: {},
    **attributes
  )
    super(**attributes)
    @radio_group = radio_group
    @value = T.let(value.to_s, String)
    @input_options = input
    @checked = checked
  end

  # == Component ==

  sig { override.void }
  def view_template
    root_element(
      :span,
      class: "radio-group-item group/radio-group-item peer",
      role: "radio",
      tabindex: 0,
      data: {
        controller: "radio",
        slot: "radio-group-item",
        checked: ("" if checked?),
        unchecked: ("" unless checked?),
        action: "click->radio#forwardItemClick",
      },
      aria: {
        checked: !!checked?,
      },
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
    if @form
      @form.radio_button(@field, @value, **input_options)
    else
      radio_button_tag(@field, @value, checked?, **input_options)
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def checked?
    if @checked.nil?
      if (object = @form&.object) && @field
        object.public_send(@field) == @value
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
        tabindex: -1,
        id: field_id(@radio_group.namespace, @value),
        aria: {
          hidden: true,
          labelledby: field_id(@radio_group.namespace, @value, :label),
        },
      },
      @input_options,
    )
  end
end
