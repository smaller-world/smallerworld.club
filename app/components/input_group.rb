# typed: strict
# frozen_string_literal: true

class Components::InputGroup < Components::Base
  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :div,
      role: "group",
      class: "input-group group/input-group",
      data: {
        slot: "input-group",
      },
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
    Components::Textarea(
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
