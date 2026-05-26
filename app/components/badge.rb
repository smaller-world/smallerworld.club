# typed: strict
# frozen_string_literal: true

class Components::Badge < Components::Base
  # == Configuration

  VARIANTS = [ :default, :secondary, :destructive, :outline, :ghost, :link ]

  # == Initialization ==

  sig { params(variant: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, **attributes)
    unless variant.in?(VARIANTS)
      raise InvalidParameter.new(parameter: :variant, value: variant)
    end

    super(**attributes)
    @variant = variant
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :span,
      class: "badge group/badge",
      data: {
        slot: "badge",
        variant: @variant.to_s,
      },
      &content
    )
  end
end
