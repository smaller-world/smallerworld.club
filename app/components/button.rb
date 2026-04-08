# typed: true
# frozen_string_literal: true

class Components::Button < Components::Base
  # == Configuration ==

  sig { params(variant: Symbol, size: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, size: :default, **attributes)
    super(**attributes)
    @variant = variant
    @size = size
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :button,
      class: "group/button",
      data: {
        slot: "button",
        variant: @variant,
        size: @size,
      },
      &content
    )
  end

  # == Helpers ==

  sig do
    params(variant: Symbol, size: Symbol)
      .returns(T::Hash[Symbol, T.untyped])
  end
  def self.attributes(variant: :default, size: :default)
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
