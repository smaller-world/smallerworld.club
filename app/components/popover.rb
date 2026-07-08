# typed: strict
# frozen_string_literal: true

class Components::Popover < Components::Base
  # == Initialization ==

  sig { params(popover_id: String).void }
  def initialize(popover_id: generate_popover_id)
    super()
    @popover_id = popover_id
    @trigger_block = T.let(nil, T.nilable(T.proc.void))
    @content_block = T.let(nil, T.nilable(T.proc.void))
  end

  # == Component ==

  sig { override.params(content: T.proc.bind(T.self_type).void).void }
  def view_template(&content)
    vanish(&content)
    trigger_block = @trigger_block or raise "Missing trigger"
    content_block = @content_block or raise "Missing content"

    trigger_block.call
    content_block.call
  end

  # == Interface ==

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.proc.params(button: Components::Button).void,
    ).void
  end
  def with_trigger_button(variant: :default, size: :default, **attributes, &content)
    @trigger_block = ->() {
      render Components::Button.new(
        variant:,
        size:,
        **mix({ popovertarget: @popover_id }, attributes),
        &content
      )
    }
  end

  sig { params(block: T.proc.void).void }
  def with_trigger(&block)
    @trigger_block = block
  end

  sig do
    params(
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      attributes: T.untyped,
      content: T.proc.params(content: Components::Popover::Content).void,
    ).void
  end
  def with_content(anchor: [ :bottom ], anchor_strategy: nil, **attributes, &content)
    @content_block = ->() {
      render Components::Popover::Content.new(
        id: @popover_id,
        anchor:,
        anchor_strategy:,
        **mix(@attributes, attributes),
        &content
      )
    }
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def generate_popover_id
    "popover_#{SecureRandom.uuid}"
  end
end
