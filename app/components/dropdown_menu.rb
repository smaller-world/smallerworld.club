# typed: true
# frozen_string_literal: true

class Components::DropdownMenu < Components::Base
  register_element :el_dropdown

  # == Configuration ==

  ITEM_VARIANTS = [ :default, :destructive ].freeze

  # == Initialization ==

  sig { params(attributes: T.untyped).void }
  def initialize(**attributes)
    @trigger_button_block = T.let(nil, T.nilable(T.proc.void))
    @content_block = T.let(nil, T.nilable(T.proc.void))
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.proc.bind(T.self_type).void).void }
  def view_template(&content)
    vanish(&content)
    trigger_button_block = @trigger_button_block or raise "Missing trigger button"
    content_block = @content_block or raise "Missing content"

    root_element(
      :el_dropdown,
      class: "dropdown-menu group/dropdown-menu",
      data: {
        slot: "dropdown-menu",
      },
    ) do
      trigger_button_block.call
      content_block.call
    end
  end

  # == Interface ==
  #
  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.proc.params(button: Components::Button).void,
    ).void
  end
  def trigger_button(variant: :default, size: :default, **attributes, &content)
    @trigger_button_block = ->() {
      render Components::Button.new(variant:, size:, **attributes, &content)
    }
  end

  sig do
    params(
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      popover: T::Boolean,
      open: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(content: Components::DropdownMenuContent).void,
    ).void
  end
  def content(
    anchor:,
    anchor_strategy: nil,
    popover: true,
    open: false,
    **attributes,
    &content
  )
    @content_block = ->() {
      render Components::DropdownMenuContent.new(
        anchor:,
        anchor_strategy:,
        popover:,
        open:,
        **attributes,
        &content
      )
    }
  end
end
