# typed: true
# frozen_string_literal: true

class Components::DropdownMenu < Components::Base
  # == Configuration ==

  register_element :el_dropdown
  register_element :el_menu

  sig do
    params(
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      popover: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    anchor: [ :bottom, :start ],
    anchor_strategy: nil,
    popover: true,
    **attributes
  )
    super(**attributes)
    @anchor = anchor
    @anchor_strategy = anchor_strategy
    @popover = popover
    @trigger_block = T.let(nil, T.nilable(T.proc.void))
    @content_block = T.let(nil, T.nilable(T.proc.void))
    @content_attributes = T.let({}, T::Hash[Symbol, T.untyped])
  end

  # == Component ==

  sig { override.params(block: T.proc.bind(T.self_type).void).void }
  def view_template(&block)
    vanish(&block)
    trigger_block = @trigger_block or raise "Missing trigger"
    root_element(
      :el_dropdown,
      class: "group/dropdown-menu",
      data: { slot: "dropdown-menu" },
    ) do
      trigger_block.call
      if (content_block = @content_block)
        el_menu(
          **mix(
            { data: { slot: "dropdown-menu-content" } },
            {
              anchor: anchor_property,
              anchor_strategy: @anchor_strategy,
              popover: @popover,
            }.compact_blank,
            @content_attributes,
          ),
          &content_block
        )
      end
    end
  end

  # == Slots ==

  sig { params(block: T.proc.void).void }
  def trigger(&block)
    @trigger_block = block
  end

  sig { params(attributes: T.untyped, block: T.proc.void).void }
  def content(**attributes, &block)
    @content_attributes = attributes
    @content_block = block
  end

  sig do
    params(
      variant: Symbol,
      inset: T::Boolean,
      attributes: T.untyped,
      block: T.proc.void,
    ).void
  end
  def link_item(variant: :default, inset: false, **attributes, &block)
    a(**mix(item_attributes(variant:, inset:), attributes), &block)
  end

  sig do
    params(
      variant: Symbol,
      inset: T::Boolean,
      attributes: T.untyped,
      block: T.proc.void,
    ).void
  end
  def button_item(variant: :default, inset: false, **attributes, &block)
    button(**mix(item_attributes(variant:, inset:), attributes), &block)
  end

  sig do
    params(
      inset: T::Boolean,
      attributes: T.untyped,
      block: T.proc.void,
    ).void
  end
  def label(inset: false, **attributes, &block)
    div(
      **mix(
        {
          data: {
            slot: "dropdown-menu-label",
            inset: inset || nil,
          },
        },
        attributes,
      ),
      &block
    )
  end

  sig { params(attributes: T.untyped).void }
  def separator(**attributes)
    div(**mix({ data: { slot: "dropdown-menu-separator" } }, attributes))
  end

  sig { params(attributes: T.untyped, block: T.proc.void).void }
  def group(**attributes, &block)
    div(**mix({ data: { slot: "dropdown-menu-group" } }, attributes), &block)
  end

  sig { params(attributes: T.untyped, block: T.proc.void).void }
  def shortcut(**attributes, &block)
    span(
      **mix({ data: { slot: "dropdown-menu-shortcut" } }, attributes),
      &block
    )
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def anchor_property
    if (values = Array.wrap(@anchor).presence)
      values.map(&:to_s).join(" ")
    end
  end

  sig { params(variant: Symbol, inset: T::Boolean).returns(T::Hash[Symbol, T.untyped]) }
  def item_attributes(variant:, inset:)
    {
      class: "group/dropdown-menu-item",
      data: {
        slot: "dropdown-menu-item",
        variant: variant == :default ? nil : variant,
        inset: inset || nil,
      },
    }
  end
end
