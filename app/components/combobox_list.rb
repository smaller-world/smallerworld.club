# typed: true
# frozen_string_literal: true

class Components::ComboboxList < Components::Base
  register_element :el_option

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :div,
      class: "combobox-list",
      data: {
        slot: "combobox-list",
      },
      &content
    )
  end

  # == Interface ==

  sig do
    params(
      value: T.any(Symbol, String),
      attributes: T.untyped,
      content: T.proc.void,
    ).void
  end
  def item(value:, **attributes, &content)
    el_option(
      value:,
      **mix(
        {
          class: "combobox-item",
          data: {
            slot: "combobox-item",
          },
        },
        attributes,
      ),
      &content
    )
  end
end
