# typed: true
# frozen_string_literal: true

class Components::InputGroupAddon < Components::Base
  # == Configuration ==

  ALIGNMENTS = [ :inline_start, :inline_end, :block_start, :block_end ]

  # == Initialization ==

  sig { params(align: Symbol, attributes: T.untyped).void }
  def initialize(align:, **attributes)
    unless align.in?(ALIGNMENTS)
      raise InvalidParameter.new(parameter: :align, value: align)
    end

    @align = T.let(align, Symbol)
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      data: {
        slot: "input-group-addon",
        align: @align.to_s.tr("_", "-"),
        controller: "input-group-addon",
        action: "click->input-group-addon#focus",
      },
      role: "group",
      &content
    )
  end

  # == Interface ==

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.params(component: Components::Button).void),
    ).void
  end
  def button(variant: :ghost, size: :xs, **attributes, &content)
    Components::Button(variant:, size:, **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def text(**attributes, &content)
    span(**mix({ data: { slot: "input-group-text" } }, attributes), &content)
  end

  sig { params(attributes: T.untyped).void }
  def spinner(**attributes)
    Components::Spinner(**attributes)
  end
end
