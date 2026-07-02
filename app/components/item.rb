# typed: strict
# frozen_string_literal: true

class Components::Item < Components::Base
  include Slot

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

    super(**attributes)
    @variant = variant
    @size = size
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
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
      content: T.proc.void,
    ).void
  end
  def media(variant: :default, **attributes, &content)
    unless variant.in?(MEDIA_VARIANTS)
      raise InvalidParameter.new(parameter: :variant, value: variant)
    end

    slot("item-media", **mix({ data: { variant: } }, attributes), &content)
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def content(**attributes, &content)
    slot("item-content", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def actions(**attributes, &content)
    slot("item-actions", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def header(**attributes, &content)
    slot("item-header", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def footer(**attributes, &content)
    slot("item-footer", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**attributes, &content)
    slot("item-title", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    slot("item-description", element: :p, **attributes, &content)
  end
end
