# typed: strict
# frozen_string_literal: true

class Components::Select < Components::Input
  register_element :el_select
  register_element :el_selectedcontent

  # == Configuration ==

  TRIGGER_SIZES = [ :default, :sm ].freeze

  # == Initialization ==

  sig do
    params(
      value: T.nilable(String),
      disabled: T::Boolean,
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(value: nil, disabled: false, invalid: false, **attributes)
    super(invalid:, **attributes)
    @value = value
    @disabled = disabled
    @trigger_block = T.let(nil, T.nilable(T.proc.void))
    @content_block = T.let(nil, T.nilable(T.proc.void))
    @selected_item_block = T.let(nil, T.nilable(T.proc.void))
  end

  sig { returns(T.nilable(String)) }
  attr_reader :value

  sig { params(selected_item_block: T.proc.void).void }
  attr_writer :selected_item_block

  # == Component ==

  sig { override.params(content: T.proc.void).returns(T.untyped) }
  def view_template(&content)
    vanish(&content)

    unless @content_block
      raise "Missing content"
    end
    unless @trigger_block
      raise "Missing trigger"
    end

    content_html = capture do
      @content_block.call
    end
    el_select(
      value: @value,
      **mix(
        {
          class: "select",
          data: {
            controller: "select",
            action: "change->select#update",
            placeholder: (true unless @value),
          },
          aria: {
            invalid: ("true" if @invalid),
          },
        },
        @attributes,
      ),
    ) do
      @trigger_block.call
      raw(content_html) # rubocop:disable Rails/OutputSafety
    end
  end

  # == Interface ==

  sig { params(size: Symbol, attributes: T.untyped, content: T.proc.void).void }
  def with_trigger(size: :default, **attributes, &content)
    @trigger_block = ->() {
      trigger(size:, **attributes, &content)
    }
  end

  sig do
    params(
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      attributes: T.untyped,
      content: T.proc.params(content: Components::Select::Content).void,
    ).void
  end
  def with_content(
    anchor: :bottom,
    anchor_strategy: nil,
    **attributes,
    &content
  )
    @content_block = ->() {
      render Components::Select::Content.new(
        self,
        anchor:,
        anchor_strategy:,
        **attributes,
        &content
      )
    }
  end

  private

  # == Helpers ==

  sig { params(size: Symbol, attributes: T.untyped, content: T.proc.void).void }
  def trigger(size: :default, **attributes, &content)
    unless size.in?(TRIGGER_SIZES)
      raise InvalidParameter.new(parameter: :size, value: size)
    end

    button(
      type: "button",
      disabled: @disabled,
      **mix(
        {
          class: "select-trigger",
          data: {
            slot: "select-trigger",
            select_target: "trigger",
            placeholder: (true unless @value),
            size:,
          },
        },
        attributes,
      ),
    ) do
      el_selectedcontent(class: "select-value", data: { slot: "select-value" }) do
        if @selected_item_block
          @selected_item_block.call
        else
          yield
        end
      end
      span do
        Icon("huge/unfold-more")
      end
    end
  end
end
