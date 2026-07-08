# typed: strict
# frozen_string_literal: true

class Components::InputGroup::Addon < Components::Base
  # == Configuration ==

  ALIGNMENTS = [ :inline_start, :inline_end, :block_start, :block_end ]

  # == Initialization ==

  sig { params(align: Symbol, attributes: T.untyped).void }
  def initialize(align: :inline_start, **attributes)
    unless align.in?(ALIGNMENTS)
      raise InvalidParameter.new(parameter: :align, value: align)
    end

    super(**attributes)
    @align = T.let(align, Symbol)
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      role: "group",
      class: "input-group-addon",
      data: {
        slot: "input-group-addon",
        align: @align,
        action: "click->input-group-addon#focusInput",
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
      content: T.proc.params(component: Components::Button).void,
    ).void
  end
  def button(variant: :ghost, size: :xs, **attributes, &content)
    Components::Button(
      type: :button,
      variant:,
      size:,
      **mix({ class: "input-group-button" }, attributes),
      &content
    )
  end

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.params(component: Components::Button).void),
    ).void
  end
  def clear_button(variant: :ghost, size: :icon_sm, **attributes, &content)
    button(variant:, size:, data: { action: "input-group-addon#clearInput" }) do |button|
      if block_given?
        yield(button)
      else
        Icon("huge/text-clear")
      end
    end
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def text(**attributes, &content)
    span(**mix({ class: "input-group-text" }, attributes), &content)
  end

  sig { params(attributes: T.untyped).void }
  def spinner(**attributes)
    Components::Spinner(**attributes)
  end
end
