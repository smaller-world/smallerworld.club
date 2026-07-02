# typed: strict
# frozen_string_literal: true

class Components::Popover::Content < Components::Base
  register_element :el_popover

  # == Configuration ==

  ANCHOR_VALUES = [ :top, :right, :bottom, :left, :start, :end ].freeze

  # == Initialization ==

  sig do
    params(
      id: String,
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(id:, anchor: [ :bottom ], anchor_strategy: nil, **attributes)
    if (Array.wrap(anchor) - ANCHOR_VALUES).any?
      raise InvalidParameter.new(parameter: :anchor, value: anchor)
    end

    super(**attributes)
    @id = id
    @anchor = anchor
    @anchor_strategy = anchor_strategy
  end

  # == Component ==

  sig { override.params(content: T.proc.bind(T.self_type).void).void }
  def view_template(&content)
    el_popover(
      **mix(
        {
          id: @id,
          class: "popover-content",
          popover: true,
          anchor: anchor_property,
          anchor_strategy: @anchor_strategy,
          data: {
            controller: "popover",
            slot: "popover-content",
          },
        },
        @attributes,
      ),
      &content
    )
  end

  # == Slots ==

  sig do
    params(
      attributes: T.untyped,
      content: T.proc.params(header: Components::Popover::Header).void,
    ).void
  end
  def header(**attributes, &content)
    render Components::Popover::Header.new(**attributes, &content)
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def anchor_property
    if (values = Array.wrap(@anchor).presence)
      values.join(" ")
    end
  end
end
