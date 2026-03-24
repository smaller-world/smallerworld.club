# typed: true
# frozen_string_literal: true

class Components::Input < Components::Base
  sig do
    params(
      form: T.nilable(Phlex::Rails::Builder),
      field: T.nilable(Symbol),
      options: T.untyped,
    ).void
  end
  def initialize(form:, field: nil, **options)
    super(**options)
    @form = form
    @field = field
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    if (form = @form) && (field = @field)
      id = form.send(:field_id, field)
      name = form.send(:field_name, field)
    end
    root_element(
      :input,
      id:,
      name:,
      data: { slot: "input" },
      &content
    )
  end
end
