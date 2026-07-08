# typed: strict
# frozen_string_literal: true

class Components::RadioGroup < Components::Base
  # == Initialization ==

  sig do
    params(
      toggleable: T::Boolean,
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(toggleable: false, invalid: false, **attributes)
    super(**attributes)
    @toggleable = toggleable
    @invalid = invalid
  end

  # == Component ==

  sig { override.params(block: T.proc.void).void }
  def view_template(&block)
    root_element(
      :div,
      class: "radio-group",
      data: {
        slot: "radio-group",
      },
      &block
    )
  end

  sig { returns(T::Boolean) }
  def toggleable?
    @toggleable
  end
end
