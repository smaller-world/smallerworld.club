# typed: true
# frozen_string_literal: true

class Components::Input < Components::Base
  sig do
    params(
      form: T.nilable(Phlex::Rails::Builder),
      field: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(form:, field: nil, **attributes)
    super(**attributes)
    @form = form
    @field = field
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    if (form = @form) && (field = @field)
      id = form.field_id(field)
      name = form.field_name(field)
      value = form.object.try(field)
    end
    root_element(
      :input,
      data: { slot: "input" },
      **{ id:, name:, value: }.compact,
      &content
    )
  end
end
