# typed: strict
# frozen_string_literal: true

class Components::RadioGroup::Item < Components::Input
  include Phlex::Rails::Helpers::RadioButtonTag

  # == Initialization ==

  sig do
    params(
      radio_group: Components::RadioGroup,
      value: String,
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      checked: T.nilable(T::Boolean),
      input: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    radio_group:,
    value:,
    form: nil,
    field: nil,
    checked: nil,
    input: {},
    **attributes
  )
    super(form:, field:, **attributes)
    @radio_group = radio_group
    @value = T.let(value.to_s, String)
    @checked = checked
    @input_options = input
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
        radio_toggleable_value: @radio_group.toggleable?,
        slot: "radio-group-item",
        checked: ("" if checked?),
        unchecked: ("" unless checked?),
        action: token_list(
          "click->radio#forwardItemClick",
        ),
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
      @form.radio_button(@field, @value, checked: checked?, **input_options)
    else
      radio_button_tag(@field, @value, checked?, **input_options)
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def checked?
    return @checked unless @checked.nil?
    return false unless (object = @form&.object) && @field

    if object.respond_to?(:type_for_attribute) &&
        (type = object.type_for_attribute(@field.to_s))
      type.cast(@value) == type.cast(object.try(@field))
    else
      object.try(@field).to_s == @value
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
