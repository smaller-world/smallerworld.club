# typed: true
# frozen_string_literal: true

class Components::BackToHomeButton < Components::Base
  # == Component ==

  sig { override.void }
  def view_template
    Components::Button(element: :a, href: home_path, variant: :secondary) do
      Icon(
        "huge/link-backward",
        class: "size-4",
        data: { icon: "inline-start" },
      )
      span { "back to home" }
    end
  end
end
