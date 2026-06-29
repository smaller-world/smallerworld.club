# typed: strict
# frozen_string_literal: true

class Components::CheckboxGroup::Field < Components::Field
  # == Initialization ==

  sig do
    params(
      checkbox_group: Components::CheckboxGroup,
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      id: T.nilable(String),
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    checkbox_group:,
    form: nil,
    field: nil,
    id: nil,
    orientation: :vertical,
    invalid: false,
    **attributes
  )
    super(form:, field:, id:, orientation:, invalid:, **attributes)
    @checkbox_group = checkbox_group
  end

  # == Interface ==

  sig do
    params(
      value: T.any(Symbol, String, Enumerize::Value),
      multiple: T::Boolean,
      checked: T.nilable(T::Boolean),
      disabled: T::Boolean,
      input: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def checkbox_group_item_for(
    value,
    multiple: true,
    checked: nil,
    disabled: false,
    input: {},
    **attributes
  )
    render Components::CheckboxGroup::Item.new(
      form: @form,
      field: @field,
      checkbox_group: @checkbox_group,
      value: value.to_s,
      multiple:,
      checked:,
      disabled:,
      input:,
      **attributes,
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def label(**attributes, &content)
    render Components::CheckboxGroup::FieldLabel.new(
      form: @form,
      field: @field,
      checkbox_group: @checkbox_group,
      **attributes,
      &content
    )
  end
end
