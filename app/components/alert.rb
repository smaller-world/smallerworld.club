# typed: strict
# frozen_string_literal: true

class Components::Alert < Components::Base
  include Slot

  # == Configuration ==

  VARIANTS = [ :default, :destructive ]

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

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      role: "alert",
      class: "alert group/alert",
      data: {
        slot: "alert",
        variant: @variant,
      },
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**attributes, &content)
    slot("alert-title", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    slot("alert-description", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def action(**attributes, &content)
    slot("alert-action", **attributes, &content)
  end
end
