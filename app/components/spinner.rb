# typed: strict
# frozen_string_literal: true

class Components::Spinner < Components::Base
  # == Component ==

  sig { override.void }
  def view_template
    Icon(
      "huge/loading-03",
      **mix(
        {
          role: "status",
          aria: { label: "Loading" },
          class: "animate-spin",
        },
        @attributes,
      ),
    )
  end
end
