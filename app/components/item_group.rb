# typed: strict
# frozen_string_literal: true

class Components::ItemGroup < Components::Base
  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      role: "list",
      class: "item-group group/item-group",
      data: {
        slot: "item-group",
      },
      &content
    )
  end

  # == Interface ==

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.proc.params(item: Components::Item).void,
    ).void
  end
  def item(variant: :default, size: :default, **attributes, &content)
    Components::Item(variant:, size:, **attributes, &content)
  end

  sig { params(attributes: T.untyped).void }
  def separator(**attributes)
    Components::Separator(
      orientation: :horizontal,
      **mix(
        {
          class: "item-separator",
          data: { slot!: "item-separator" },
        },
        attributes,
      ),
    )
  end
end
