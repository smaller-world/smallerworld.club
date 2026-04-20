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
    @variant = variant
    @size = size
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :button,
      **self.class.root_attributes(variant: @variant, size: @size),
      &content
    )
  end

  # == Interface ==

  sig do
    params(name: String, align: T.nilable(String), attributes: T.untyped).void
  end
  def icon(name, align:, **attributes)
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

  sig do
    params(variant: Symbol, size: T.any(Symbol, String))
      .returns(T::Hash[Symbol, T.untyped])
  end
  def self.root_attributes(variant: :default, size: :default)
    {
      class: "group/button",
      data: {
        slot: "button",
        variant:,
        size:,
      },
    }
  end
end
