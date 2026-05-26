# typed: strict
# frozen_string_literal: true

class Components::Combobox < Components::Base
  register_element :el_autocomplete

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      clear_on_expand: T.nilable(T::Boolean),
      disabled: T::Boolean,
      default_value: T.nilable(String),
      input: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    form: nil,
    field: nil,
    clear_on_expand: nil,
    disabled: false,
    default_value: nil,
    input: {},
    **attributes
  )
    @form = form
    @field = field
    @clear_on_expand = clear_on_expand
    @disabled = disabled
    @input_options = input
    @inline_start_addon_block = T.let(
      nil,
      T.nilable(T.proc.params(group: Components::InputGroup).void),
    )
    @content_block = T.let(nil, T.nilable(T.proc.void))
    @default_value = default_value
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    vanish(&content)
    content_block = @content_block or raise "Missing content"

    el_autocomplete(
      data: {
        controller: "combobox",
        combobox_clear_on_expand_value: @clear_on_expand,
      },
    ) do
      Components::InputGroup(
        form: @form,
        field: @field,
        **mix(
          {
            class: "combobox-input-group",
            data: {
              disabled: ("true" if @disabled),
            },
          },
          @attributes,
        ),
      ) do |group|
        @inline_start_addon_block&.call(group)
        group.input(
          disabled: @disabled,
          **mix(
            {
              data: {
                combobox_target: "input",
                action: [
                  "change->combobox#normalizeSelection",
                  "keydown.enter->combobox#blur",
                ],
              },
            },
            @input_options,
          ),
        )
        group.addon(align: :inline_end) do |addon|
          addon.button(
            type: :button,
            size: :icon_xs,
            variant: :ghost,
            disabled: @disabled,
            class: "comobox-trigger",
            data: {
              slot: "combobox-trigger",
            },
          ) do
            Icon("huge/arrow-down-01")
          end
        end
      end

      content_block.call
    end
  end

  # == Interface ==

  sig do
    params(
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      popover: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(content: Components::Combobox::Content).void,
    ).void
  end
  def with_content(anchor:, anchor_strategy: nil, popover: true, **attributes, &content)
    @content_block = ->() {
      render Components::Combobox::Content.new(
        anchor:,
        anchor_strategy:,
        popover:,
        **attributes,
        &content
      )
    }
  end

  sig do
    params(
      attributes: T.untyped,
      content: T.proc.params(addon: Components::InputGroup::Addon).void,
    ).void
  end
  def with_inline_start_addon(**attributes, &content)
    @inline_start_addon_block = ->(group) {
      group.addon(align: :inline_start, **attributes, &content)
    }
  end
end
