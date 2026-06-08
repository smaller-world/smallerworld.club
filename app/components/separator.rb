# typed: strict
# frozen_string_literal: true

class Components::Separator < Components::Base
  sig { params(orientation: Symbol, decorative: T::Boolean, attributes: T.untyped).void }
  def initialize(orientation: :horizontal, decorative: true, **attributes)
    super(**attributes)
    @orientation = orientation
    @decorative = decorative
  end

  # == Component ==

  sig { override.void }
  def view_template
    root_element(
      :div,
      role: (@decorative ? "none" : "separator"),
      class: "separator",
      data: {
        slot: "separator",
        orientation: @orientation,
      },
      aria: {
        orientation: (:vertical if @decorative && @orientation == :vertical),
      },
    )
  end
end
