# typed: true
# frozen_string_literal: true

class Components::Item < Components::Base
  # == Configuration ==

  VARIANTS = [ :default, :outline, :muted ]
  MEDIA_VARIANTS = [ :default, :icon, :image ]
  SIZES = [ :default, :xs, :sm ]

  # == Initialization ==

  sig { params(variant: Symbol, size: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, size: :default, **attributes)
    unless variant.in?(VARIANTS)
      raise InvalidParameter.new(parameter: :variant, value: variant)
    end
    unless size.in?(SIZES)
      raise InvalidParameter.new(parameter: :size, value: size)
    end

    @variant = variant
    @size = size
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      class: "item group/item",
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
    unless variant.in?(MEDIA_VARIANTS)
      raise InvalidParameter.new(parameter: :variant, value: variant)
    end

    slot("item-media", **mix({ data: { variant: } }, attributes, &content))
  end

  sig do
    params(
      attributes: T.untyped,
      content: T.proc.params(content: Components::ItemContent).void,
    ).void
  end
  def content(**attributes, &content)
    Components::ItemContent(**attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def actions(**attributes, &content)
    slot("item-actions", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def header(**attributes, &content)
    slot("item-header", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def footer(**attributes, &content)
    slot("item-footer", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def separator(**attributes, &content)
    Components::Separator(
      orientation: :horizontal,
      class: "item-separator",
      data: { slot!: "item-separator" },
    )
  end

  private

  # == Helpers ==

  sig { params(name: String, attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def slot(name, **attributes, &content)
    div(class: name, data: { slot: name }, **attributes, &content)
  end
end
