# typed: strict
# frozen_string_literal: true

class Components::Select::Content < Components::Base
  include Slot

  register_element :el_options
  register_element :el_option

  # == Configuration ==

  ANCHOR_VALUES = [ :top, :right, :bottom, :left, :start, :end ].freeze

  # == Initialization ==

  sig do
    params(
      select: Components::Select,
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(
    select,
    anchor: :bottom,
    anchor_strategy: nil,
    **attributes
  )
    if (Array.wrap(anchor) - ANCHOR_VALUES).any?
      raise InvalidParameter.new(parameter: :anchor, value: anchor)
    end

    super(**attributes)
    @select = select
    @anchor = anchor
    @anchor_strategy = anchor_strategy
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    el_options(
      popover: true,
      anchor: anchor_property,
      anchor_strategy: @anchor_strategy,
      **mix(
        {
          class: "select-content",
          data: {
            slot: "select-content",
          },
        },
        @attributes,
      ),
      &content
    )
  end

  # == Interface ==

  sig { params(value: String, attributes: T.untyped, content: T.proc.void).void }
  def item(value:, **attributes, &content)
    selected = @select.value == value
    if selected
      @select.selected_item_block = content
    end
    div(**mix(
      {
        class: "select-item",
        data: {
          controller: "forward-click",
          slot: "select-item",
        },
      },
      attributes,
    )) do
      item_text(value:, selected:, &content)
      span(class: "select-item-indicator") do
        Icon("huge/tick-02")
      end
    end
  end

  sig { params(attributes: T.untyped).void }
  def blank_item(**attributes)
    selected = @select.value.nil?
    div(**mix(
      {
        class: "select-item",
        data: {
          controller: "forward-click",
          slot: "select-item",
        },
      },
      attributes,
    )) do
      item_text(selected:)
      span(class: "select-item-indicator") do
        Icon("huge/tick-02")
      end
    end
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def group(**attributes, &content)
    slot("select-group", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def label(**attributes, &content)
    slot("select-label", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def separator(**attributes, &content)
    slot("select-separator", **attributes, &content)
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def anchor_property
    if (values = Array.wrap(@anchor).presence)
      values.join(" ")
    end
  end

  sig do
    params(
      value: T.nilable(String),
      selected: T.nilable(T::Boolean),
      content: T.nilable(T.proc.void),
    ).void
  end
  def item_text(value: nil, selected: false, &content)
    el_option(
      value:,
      class: "select-item-text",
      data: {
        forward_click_target: "clickable",
      },
      aria: {
        selected: (selected.to_s unless selected.nil?),
      },
      &content
    )
  end
end
