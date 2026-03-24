# typed: true
# frozen_string_literal: true

class Components::FieldGroup < Components::Base
  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      class: "group/field-group",
      data: { slot: "field-group" },
      &content
    )
  end
end
