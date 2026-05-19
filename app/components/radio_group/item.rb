# typed: true
# frozen_string_literal: true

class Components::RadioGroup::Item < Components::Input
  include Phlex::Rails::Helpers::RadioButtonTag

  # == Initialization ==

  sig do
    params(
      value: T.any(Symbol, String, Enumerize::Value),
      input: T::Hash[Symbol, T.untyped],
      radio_group: Components::RadioGroup,
      checked: T.nilable(T::Boolean),
      attributes: T.untyped,
    ).void
  end
  def initialize(
    value:,
    input:,
    radio_group:,
    checked: nil,
    **attributes
  )
    @value = value.to_s
    @input_options = input
    @radio_group = radio_group
    @checked = checked
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    input_options = mix(
      {
        tabindex: -1,
        id: field_id(@radio_group.namespace, @value),
        data: {
          radio_group_target: "itemInput",
          action: "change->radio-group#select",
        },
        aria: {
          hidden: true,
          labelledby: field_id(@radio_group.namespace, @value),
        },
      },
      @input_options,
    )

    root_element(
      :span,
      class: "radio-group-item group/radio-group-item peer",
      role: "radio",
      tabindex: 0,
      data: {
        slot: "radio-group-item",
        checked: ("" if checked?),
        unchecked: ("" unless checked?),
        action: "click->radio-group#forwardItemClick",
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
end
