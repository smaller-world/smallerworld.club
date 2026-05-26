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
end
