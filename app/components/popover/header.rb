# typed: strict
# frozen_string_literal: true

class Components::Popover::Header < Components::Base
  include Slot

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      class: "popover-header",
      data: {
        slot: "popover-header",
      },
      &content
    )
  end

  # == Slots ==

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**attributes, &content)
    slot("popover-title", element: :h4, **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    slot("popover-description", element: :p, **attributes, &content)
  end
end
