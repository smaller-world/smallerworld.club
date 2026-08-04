# typed: strict
# frozen_string_literal: true

class Components::Textarea < Components::Input
  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :textarea,
      class: "textarea",
      aria: {
        invalid: ("true" if @invalid),
      },
      data: {
        slot: "textarea",
      },
      &content
    )
  end
end
