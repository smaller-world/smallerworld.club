# typed: strict
# frozen_string_literal: true

class Components::Dialog::Header < Components::Base
  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :div,
      class: "dialog_header",
      data: {
        slot: "dialog-header",
      },
      &content
    )
  end

  # == Slots ==

  sig { params(attributes: T.untyped, block: T.proc.void).void }
  def title(**attributes, &block)
    h2(
      **mix(
        {
          class: "dialog_title",
          data: {
            slot: "dialog-title",
          },
        },
        attributes,
      ),
      &block
    )
  end

  sig { params(attributes: T.untyped, block: T.proc.void).void }
  def description(**attributes, &block)
    p(
      **mix(
        {
          class: "dialog_description",
          data: {
            slot: "dialog-description",
          },
        },
        attributes,
      ),
      &block
    )
  end
end
