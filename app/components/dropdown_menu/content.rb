# typed: strict
# frozen_string_literal: true

class Components::DropdownMenu::Content < Components::Base
  register_element :el_menu

  # == Configuration ==

  ITEM_VARIANTS = [ :default, :destructive ]
  ANCHOR_VALUES = [ :top, :right, :bottom, :left, :start, :end ].freeze

  # == Initialization ==

  sig do
    params(
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      open: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    anchor: [ :bottom, :start ],
    anchor_strategy: nil,
    open: false,
    **attributes
  )
    if (Array.wrap(anchor) - ANCHOR_VALUES).any?
      raise InvalidParameter.new(parameter: :anchor, value: anchor)
    end

    super(**attributes)
    @anchor = anchor
    @anchor_strategy = anchor_strategy
    @open = open
  end

  # == Component ==

  sig { override.params(content: T.proc.bind(T.self_type).void).void }
  def view_template(&content)
    el_menu(
      **mix(
        {
          popover: true,
          anchor: anchor_property,
          anchor_strategy: @anchor_strategy,
          class: "dropdown-menu-content",
          data: {
            dropdown_menu_target: "menu",
            slot: "dropdown-menu-content",
          },
        },
        @attributes,
      ),
      &content
    )
  end

  # == Interface ==

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
          class: "dropdown-menu-label",
          data: {
            slot: "dropdown-menu-label",
            inset: (true if inset),
          },
        },
        attributes,
      ),
      &block
    )
  end

  sig do
    params(
      variant: Symbol,
      inset: T::Boolean,
      disabled: T::Boolean,
      attributes: T.untyped,
      content: T.proc.void,
    ).void
  end
  def link_item(variant: :default, inset: false, disabled: false, **attributes, &content)
    item(:a, variant:, inset:, disabled:, **attributes, &content)
  end

  sig do
    params(
      target: Object,
      variant: Symbol,
      inset: T::Boolean,
      disabled: T::Boolean,
      attributes: T.untyped,
      content: T.proc.void,
    ).void
  end
  def link_item_to(target, variant: :default, inset: false, disabled: false, **attributes, &content)
    item(:a, variant:, inset:, href: url_for(target), disabled:, **attributes, &content)
  end

  sig do
    params(
      variant: Symbol,
      inset: T::Boolean,
      disabled: T::Boolean,
      attributes: T.untyped,
      content: T.proc.void,
    ).void
  end
  def button_item(variant: :default, inset: false, disabled: false, **attributes, &content)
    item(:button, variant:, inset:, disabled:, **mix({ type: :button }, attributes), &content)
  end

  sig { params(attributes: T.untyped).void }
  def separator(**attributes)
    div(**mix(
      {
        class: "dropdown-menu-separator",
        data: {
          slot: "dropdown-menu-separator",
        },
      },
      attributes,
    ))
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def group(**attributes, &content)
    div(**mix({ data: { slot: "dropdown-menu-group" } }, attributes), &content)
  end

  private

  # == Subcomponents ==

  sig do
    params(
      element: Symbol,
      variant: Symbol,
      inset: T::Boolean,
      disabled: T::Boolean,
      attributes: T.untyped,
      content: T.proc.void,
    ).void
  end
  def item(
    element,
    variant: :default,
    inset: false,
    disabled: false,
    **attributes, &content
  )
    unless variant.in?(ITEM_VARIANTS)
      raise InvalidParameter.new(parameter: :variant, value: variant)
    end

    public_send(
      element,
      **mix(
        {
          class: "dropdown-menu-item group/dropdown-menu-item",
          disabled: (true if disabled && element == :button),
          data: {
            slot: "dropdown-menu-item",
            variant: variant,
            inset: (true if inset),
            disabled: (true if disabled),
          },
        },
        attributes,
      ),
      &content
    )
  end

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def anchor_property
    if (values = Array.wrap(@anchor).presence)
      values.join(" ")
    end
  end
end
