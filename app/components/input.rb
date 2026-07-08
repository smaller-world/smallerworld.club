# typed: strict
# frozen_string_literal: true

class Components::Input < Components::Base
  # == Initialization ==

  sig { params(invalid: T::Boolean, attributes: T.untyped).void }
  def initialize(invalid: false, **attributes)
    super(**attributes)
    @invalid = invalid
  end

  # == Component ==

  sig { override.void }
  def view_template
    slot = @attributes[:data]&.delete(:slot) || "input"
    root_element(
      :input,
      class: "input",
      data: {
        slot:,
      },
      aria: {
        invalid: ("true" if @invalid),
      },
    )
  end
end
