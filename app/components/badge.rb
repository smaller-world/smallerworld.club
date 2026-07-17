# typed: strict
# frozen_string_literal: true

class Components::Badge < Components::Polymorphic
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

  # == Interface ==

  sig { params(name: String, attributes: T.untyped).void }
  def inline_start_icon(name, **attributes)
    Icon(name, **mix({ data: { icon: :inline_start } }, attributes))
  end

  sig { params(name: String, attributes: T.untyped).void }
  def inline_end_icon(name, **attributes)
    Icon(name, **mix({ data: { icon: :inline_end } }, attributes))
  end
end
