# typed: strict
# frozen_string_literal: true

class Components::Select::Content < Components::Base
  register_element :el_options
  register_element :el_option

  # == Configuration ==

  ANCHOR_VALUES = [ :top, :right, :bottom, :left, :start, :end ].freeze

  # == Initialization ==

  sig do
    params(
      value: T.nilable(String),
      register_selected_item_block: T.proc.params(selected_item_block: T.proc.void).void,
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      popover: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    value:,
    register_selected_item_block:,
    anchor: :bottom,
    anchor_strategy: nil,
    popover: true,
    **attributes
  )
    if (Array.wrap(anchor) - ANCHOR_VALUES).any?
      raise InvalidParameter.new(parameter: :anchor, value: anchor)
    end

    super(**attributes)
    @value = value
    @register_selected_item_block = register_selected_item_block
    @anchor = anchor
    @anchor_strategy = anchor_strategy
    @popover = popover
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    el_options(
      popover: (true if @popover),
      anchor: anchor_property,
      "anchor-strategy" => @anchor_strategy,
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
    div(**mix(
      {
        class: "select-item",
        data: {
          slot: "select-item",
        },
      },
      attributes,
    )) do
      el_option(value:, class: "select-item-text", &content)
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
      name: String,
      element: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def slot(name, element: :div, **attributes, &content)
    public_send(
      element,
      **mix(
        {
          class: name,
          data: {
            slot: name,
          },
        },
        attributes,
      ),
      &content
    )
  end
end
