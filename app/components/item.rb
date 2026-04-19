# typed: true
# frozen_string_literal: true

class Components::Item < Components::Base
  sig { params(variant: Symbol, size: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, size: :default, **attributes)
    super(**attributes)
    @variant = variant
    @size = size
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      class: "group/item",
      data: {
        slot: "item",
        variant: @variant,
        size: @size,
      },
      &content
    )
  end

  sig do
    params(
      variant: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def media(variant: :default, **attributes, &content)
    div(**mix({ data: { slot: "item-media", variant: } }, attributes), &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def content(**attributes, &content)
    div(**mix({ data: { slot: "item-content" } }, attributes), &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**attributes, &content)
    div(**mix({ data: { slot: "item-title" } }, attributes), &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    p(**mix({ data: { slot: "item-description" } }, attributes), &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def actions(**attributes, &content)
    div(**mix({ data: { slot: "item-actions" } }, attributes), &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def header(**attributes, &content)
    div(**mix({ data: { slot: "item-header" } }, attributes), &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def footer(**attributes, &content)
    div(**mix({ data: { slot: "item-footer" } }, attributes), &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def separator(**attributes, &content)
    div(data: { slot: "item-separator" }, **attributes) do
      render Components::Separator(orientation: :horizontal)
    end
  end
end
