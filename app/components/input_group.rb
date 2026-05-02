# typed: true
# frozen_string_literal: true

class Components::InputGroup < Components::Base
  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, **attributes)
    @form = form
    @field = field
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      role: "group",
      class: "input-group group/input-group",
      data: { slot: "input-group" },
      &content
    )
  end

  # == Interface ==

  sig { params(options: T.untyped).void }
  def input(**options)
    Components::Input(
      form: @form,
      field: @field,
      **mix(
        {
          class: "input-group-input",
          data: {
            slot!: "input-group-control",
          },
        },
        options,
      ),
    )
  end

  sig { params(options: T.untyped).void }
  def text_input(**options)
    input(type: :text, **options)
  end

  sig { params(direct_upload: T::Boolean, options: T.untyped).void }
  def file_input(direct_upload: true, **options)
    Components::FileInput(
      form: @form,
      field: @field,
      direct_upload:,
      **mix(
        {
          class: "input-group-input",
          data: {
            slot!: "input-group-control",
          },
        },
        options,
      ),
    )
  end

  sig do
    params(
      options: T.untyped,
      content: T.proc.params(component: Components::Textarea).void,
    ).void
  end
  def textarea(**options, &content)
    Components::Textarea(
      form: @form,
      field: @field,
      **mix(
        {
          class: "input-group-textarea",
          data: {
            slot!: "input-group-control",
          },
        },
        options,
      ),
      &content
    )
  end

  sig do
    params(
      align: Symbol,
      attributes: T.untyped,
      content: T.proc.params(component: Components::InputGroupAddon).void,
    ).void
  end
  def addon(align:, **attributes, &content)
    render Components::InputGroupAddon.new(align:, **attributes, &content)
  end
end
