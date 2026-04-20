# typed: true
# frozen_string_literal: true

class Components::Badge < Components::Base
  # == Configuration ==

  sig { params(variant: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, **attributes)
    @variant = variant
    super(**attributes)
  end

  # == Component ==

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
