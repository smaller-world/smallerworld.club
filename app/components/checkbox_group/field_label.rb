# typed: strict
# frozen_string_literal: true

class Components::CheckboxGroup::FieldLabel < Components::FieldLabel
  # == Initialization ==

  sig do
    params(
      checkbox_group: Components::CheckboxGroup,
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      id: T.nilable(String),
      attributes: T.untyped,
    ).void
  end
  def initialize(checkbox_group:, form: nil, field: nil, id: nil, **attributes)
    super(form:, field:, id:, **attributes)
    @checkbox_group = checkbox_group
  end

  # == Interface ==

  sig do
    params(
      id: T.nilable(String),
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(field: Components::CheckboxGroup::Field).void,
    ).void
  end
  def field(
    id: nil,
    orientation: :vertical,
    invalid: false,
    **attributes,
    &content
  )
    render Components::CheckboxGroup::Field.new(
      form: @form,
      field: @field,
      checkbox_group: @checkbox_group,
      id:,
      orientation:,
      invalid:,
      **attributes,
      &content
    )
  end
end
