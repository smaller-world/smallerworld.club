# typed: strict
# frozen_string_literal: true

module Slot
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::HTML }

  # == Methods ==

  sig do
    params(
      name: String,
      element: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def slot(name, element: :div, **attributes, &content)
    public_send(
      element,
      **mix(
        {
          class: name,
          data: {
            slot: name,
          },
        },
        attributes,
      ),
      &content
    )
  end
end
