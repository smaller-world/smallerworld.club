# typed: true
# frozen_string_literal: true

class Components::Badge < Components::Base
  sig { params(variant: Symbol, options: T.untyped).void }
  def initialize(variant: :default, **options)
    super(**options)
    @variant = variant
  end

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    span(
      class: "group/badge",
      data: {
        slot: "badge",
        variant: @variant,
      },
      &content
    )
  end
end
