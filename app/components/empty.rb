# typed: strict
# frozen_string_literal: true

class Components::Empty < Components::Base
  include Slot

  # == Configuration ==

  MEDIA_VARIANTS = [ :default, :icon ]

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :div,
      class: "empty group/empty",
      data: {
        slot: "empty",
      },
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def header(**attributes, &content)
    slot("empty-header", **attributes, &content)
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

    slot("empty-media", **mix({ data: { variant: } }, attributes), &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**attributes, &content)
    slot("empty-title", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    slot("empty-description", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def content(**attributes, &content)
    slot("empty-content", **attributes, &content)
  end
end
