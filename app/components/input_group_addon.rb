# typed: true
# frozen_string_literal: true

class Components::InputGroupAddon < Components::Base
  # == Configuration ==

  sig { params(align: String, attributes: T.untyped).void }
  def initialize(align:, **attributes)
    super(**attributes)
    @align = T.let(align, T.nilable(String))
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      data: {
        slot: "input-group-addon",
        align: @align,
        controller: "input-group-addon",
        action: "click->input-group-addon#focus",
      },
      role: "group",
      &content
    )
  end

  # == Interface ==

  sig do
    params(
      variant: Symbol,
      size: T.any(Symbol, String),
      attributes: T.untyped,
      content: T.nilable(T.proc.params(component: Components::Button).void),
    ).void
  end
  def button(variant: :ghost, size: :xs, **attributes, &content)
    Components::Button(variant:, size:, **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def text(**attributes, &content)
    span(**mix({ data: { slot: "input-group-text" } }, attributes), &content)
  end

  sig { params(attributes: T.untyped).void }
  def spinner(**attributes)
    Components::Spinner(**attributes)
  end
end
