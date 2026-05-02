# typed: true
# frozen_string_literal: true

class Components::ComboboxContent < Components::Base
  register_element :el_options
  register_element :el_option

  # == Initialization ==

  sig do
    params(
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      popover: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(anchor:, anchor_strategy: nil, popover: true, **attributes)
    @anchor = anchor
    @anchor_strategy = anchor_strategy
    @popover = popover
    @empty_block = T.let(nil, T.nilable(T.proc.void))
    @list_block = T.let(nil, T.nilable(T.proc.void))
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    vanish(&content)
    list_block = @list_block or raise "Missing list"

    el_options(
      **mix(
        {
          popover: (true if @popover),
          anchor: anchor_property,
          "anchor-strategy" => @anchor_strategy,
          class: "combobox-content group/combobox-content",
          data: {
            slot: "combobox-content",
          },
        },
        @attributes,
      ),
    ) do
      if (block = @empty_block)
        block.call
      else
        empty { "no items found" }
      end
      list_block.call
    end
  end

  # == Interface ==

  sig do
    params(
      attributes: T.untyped,
      content: T.proc.void,
    ).void
  end
  def with_empty(**attributes, &content)
    @empty_block = ->() {
      empty(**attributes, &content)
    }
  end

  sig do
    params(
      attributes: T.untyped,
      content: T.proc.params(list: Components::ComboboxList).void,
    ).void
  end
  def with_list(**attributes, &content)
    @list_block = ->() {
      Components::ComboboxList(**attributes, &content)
    }
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def anchor_property
    if (values = Array.wrap(@anchor).presence)
      values.map(&:to_s).join(" ")
    end
  end

  sig { params(attributes: T.untyped, content: T.proc.void).void }
  def empty(**attributes, &content)
    div(
      **mix(
        {
          class: "combobox-empty",
          data: {
            slot: "combobox-empty",
          },
        },
        attributes,
      ),
      &content
    )
  end
end
