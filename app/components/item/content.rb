# typed: strict
# frozen_string_literal: true

class Components::Item::Content < Components::Base
  include Slot

  # == Component ==

  sig { override.params(content: T.proc.bind(T.self_type).void).void }
  def view_template(&content)
    root_element(
      :div,
      class: "item-content",
      data: {
        slot: "item-content",
      },
      &content
    )
  end

  # == Interface ==

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**attributes, &content)
    slot("item-title", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    slot("item-description", element: :p, **attributes, &content)
  end
end
