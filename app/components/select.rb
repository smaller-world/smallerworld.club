# typed: strict
# frozen_string_literal: true

class Components::Select < Components::Input
  include Phlex::Rails::Helpers::HiddenFieldTag

  register_element :el_select
  register_element :el_selectedcontent

  # == Configuration ==

  TRIGGER_SIZES = [ :default, :sm ].freeze

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      value: T.nilable(T.any(String, Symbol)),
      disabled: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, value: nil, disabled: false, **attributes)
    super(form:, field:, **attributes)
    @value = value
    @disabled = disabled
    @trigger_block = T.let(nil, T.nilable(T.proc.void))
    @content_block = T.let(nil, T.nilable(T.proc.void))
    @selected_item_block = T.let(nil, T.nilable(T.proc.void))
  end

  # == Initialization ==

  sig { override.params(content: T.proc.void).returns(T.untyped) }
  def view_template(&content)
    vanish(&content)
    content_block = @content_block or raise "Missing content"

    el_select(
      **mix(
        {
          class: "select",
          data: {
            controller: "select",
            action: "change->select#update",
            placeholder: (true unless field_value),
          },
          aria: {
            invalid: ("true" if field_has_errors?),
          },
        },
        field_options,
        @attributes,
      ),
    ) do
      content_html = capture do
        content_block.call
      end
      if (block = @trigger_block)
        block.call
      else
        trigger
      end
      raw(content_html) # rubocop:disable Rails/OutputSafety
    end
  end

  # == Interface ==

  sig do
    params(
      size: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.void),
    ).void
  end
  def with_trigger(size: :default, **attributes, &content)
    @trigger_block = ->() { trigger(size:, **attributes, &content) }
  end

  sig do
    params(
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      popover: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(options: Components::Select::Content).void,
    ).void
  end
  def with_content(
    anchor: :bottom,
    anchor_strategy: nil,
    popover: true,
    **attributes,
    &content
  )
    @content_block = ->() {
      render Components::Select::Content.new(
        value: field_value,
        register_selected_item_block: ->(selected_item_block) {
          @selected_item_block = selected_item_block
        },
        anchor:,
        anchor_strategy:,
        popover:,
        **attributes,
        &content
      )
    }
  end

  private

  # == Helpers ==

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def field_options
    {
      id: field_id,
      name: field_name,
      value: field_value,
    }.compact
  end

  sig { returns(T.nilable(String)) }
  def field_id
    if @form && @field
      @form.field_id(@field)
    elsif @field
      super(@field)
    end
  end

  sig { returns(T.nilable(String)) }
  def field_name
    if @form && @field
      @form.field_name(@field)
    elsif @field
      super(@field)
    end
  end

  sig { returns(T.nilable(String)) }
  def field_value
    if @form && @field
      @form.object.public_send(@field)
    elsif @value
      @value.to_s
    end
  end

  sig { params(size: Symbol, attributes: T.untyped, content: T.nilable(T.proc.void)).void }
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
            placeholder: (true unless field_value),
            size:,
          },
        },
        attributes,
      ),
    ) do
      el_selectedcontent(class: "select-value", data: { slot: "select-value" }) do
        if @selected_item_block
          @selected_item_block.call
        elsif content
          yield
        else
          @field.to_s.humanize(capitalize: false)
        end
      end
      span do
        Icon("huge/unfold-more")
      end
    end
  end
end
