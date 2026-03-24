# typed: true
# frozen_string_literal: true

class Components::Separator < Components::Base
  sig { params(orientation: Symbol, decorative: T::Boolean, options: T.untyped).void }
  def initialize(orientation: :horizontal, decorative: true, **options)
    super(**options)
    @orientation = orientation
    @decorative = decorative
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      role: (@decorative ? "none" : "separator"),
      data: {
        slot: "separator",
        orientation: @orientation,
      },
      aria: {
        orientation: (:vertical if @decorative && @orientation == :vertical),
      },
      &content
    )
  end
end
