# typed: true
# frozen_string_literal: true

class Components::ItemContent < Components::Base
  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
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
    div(
      **mix(
        {
          class: "item-title",
          data: { slot: "item-title" },
        },
        attributes,
      ),
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    p(
      **mix(
        {
          class: "item-description",
          data: {
            slot: "item-description",
          },
        },
        attributes,
      ),
      &content
    )
  end
end
