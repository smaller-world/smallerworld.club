# typed: true
# frozen_string_literal: true

class Components::RadioGroup::FieldLabel < Components::FieldLabel
  # == Initialization ==

  sig do
    params(
      radio_group: Components::RadioGroup,
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      id: T.nilable(String),
      attributes: T.untyped,
    ).void
  end
  def initialize(radio_group:, form: nil, field: nil, id: nil, **attributes)
    @radio_group = radio_group
    super(form:, field:, id:, **attributes)
  end

  # == Interface ==

  sig do
    params(
      id: T.nilable(String),
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(field: Components::RadioGroup::Field).void,
    ).void
  end
  def field(
    id: nil,
    orientation: :vertical,
    invalid: false,
    **attributes,
    &content
  )
    render Components::RadioGroup::Field.new(
      form: @form,
      field: @field,
      id:,
      orientation:,
      invalid:,
      radio_group: @radio_group,
      **attributes,
      &content
    )
  end
end
