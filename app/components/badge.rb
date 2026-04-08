# typed: true
# frozen_string_literal: true

class Components::Badge < Components::Base
  # == Configuration ==

  sig { params(variant: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, **attributes)
    super(**attributes)
    @variant = variant
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
