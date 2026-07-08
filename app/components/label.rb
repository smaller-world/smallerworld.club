# typed: strict
# frozen_string_literal: true

class Components::Label < Components::Base
  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :label,
      class: "label",
      data: {
        slot: "label",
      },
      &content
    )
  end
end
