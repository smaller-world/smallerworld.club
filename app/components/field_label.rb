# typed: strict
# frozen_string_literal: true

class Components::FieldLabel < Components::Base
  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :label,
      class: "field-label group/field-label peer/field-label",
      data: {
        slot: "field-label",
      },
      &content
    )
  end
end
