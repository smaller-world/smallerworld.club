# typed: true
# frozen_string_literal: true

class Components::Button < Components::Base
  # == Configuration ==

  sig do
    params(
      variant: Symbol,
      size: T.any(Symbol, String),
      attributes: T.untyped,
    ).void
  end
  def initialize(variant: :default, size: :default, **attributes)
    super(**attributes)
    @variant = variant
    @size = size
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(:button, **root_attributes, &content)
  end

  # == Interface ==

  sig { params(name: String, align: T.nilable(String), attributes: T.untyped).void }
  def icon(name, align: nil, **attributes)
    Icon(
      name,
      **mix(
        {
          data: { icon: align }.compact,
        },
        attributes,
      ),
    )
  end

  # == Helpers ==

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def root_attributes
    {
      class: "group/button",
      data: {
        slot: "button",
        variant: @variant,
        size: @size,
      },
    }
  end
end
