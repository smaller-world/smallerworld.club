# typed: strict
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
    super(**attributes)
    @form = form
    @field = field
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
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

  sig do
    params(
      align: Symbol,
      attributes: T.untyped,
      content: T.proc.params(component: Components::InputGroup::Addon).void,
    ).void
  end
  def addon(align: :inline_start, **attributes, &content)
    render Components::InputGroup::Addon.new(align:, **attributes, &content)
  end

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.proc.params(component: Components::Button).void,
    ).void
  end
  def button(variant: :ghost, size: :xs, **attributes, &content)
    render Components::Button.new(
      variant:,
      size:,
      **mix({ class: "input-group-button" }, attributes),
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def text(**attributes, &content)
    span(**mix({ class: "input-group-text" }, attributes), &content)
  end

  sig { params(attributes: T.untyped).void }
  def input(**attributes)
    render Components::Input.new(
      form: @form,
      field: @field,
      **mix(
        {
          class: "input-group-input",
          data: {
            slot!: "input-group-control",
          },
        },
        attributes,
      ),
    )
  end

  sig { params(attributes: T.untyped).void }
  def text_input(**attributes)
    input(type: :text, **attributes)
  end

  sig { params(direct_upload: T::Boolean, attributes: T.untyped).void }
  def file_input(direct_upload: true, **attributes)
    render Components::FileInput.new(
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
        attributes,
      ),
    )
  end

  sig { params(attributes: T.untyped).void }
  def textarea(**attributes)
    render Components::Textarea.new(
      form: @form,
      field: @field,
      **mix(
        {
          class: "input-group-textarea",
          data: {
            slot!: "input-group-control",
          },
        },
        attributes,
      ),
    )
  end
end
