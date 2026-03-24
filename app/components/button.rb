# typed: true
# frozen_string_literal: true

class Components::Button < Components::Base
  sig { params(variant: Symbol, size: Symbol, options: T.untyped).void }
  def initialize(variant: :default, size: :default, **options)
    super(**options)
    @variant = variant
    @size = size
  end

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
end
