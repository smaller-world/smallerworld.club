# typed: strict
# frozen_string_literal: true

class Components::RadioGroup::Field < Components::Field
  # == Initialization ==

  sig do
    params(
      radio_group: Components::RadioGroup,
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      id: T.nilable(String),
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    radio_group:,
    form: nil,
    field: nil,
    id: nil,
    orientation: :vertical,
    invalid: false,
    **attributes
  )
    super(form:, field:, id:, orientation:, invalid:, **attributes)
    @radio_group = radio_group
  end

  # == Interface ==

  sig do
    params(
      value: T.any(Symbol, String),
      input: T::Hash[Symbol, T.untyped],
      checked: T.nilable(T::Boolean),
      attributes: T.untyped,
    ).void
  end
  def radio_group_item_for(
    value,
    input: {},
    checked: nil,
    **attributes
  )
    render Components::RadioGroup::Item.new(
      radio_group: @radio_group,
      form: @form,
      field: @field,
      value: value.to_s,
      input:,
      checked:,
      **attributes,
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def label(**attributes, &content)
    render Components::RadioGroup::FieldLabel.new(
      form: @form,
      field: @field,
      radio_group: @radio_group,
      **attributes,
      &content
    )
  end
end
