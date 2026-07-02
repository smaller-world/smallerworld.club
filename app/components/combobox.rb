# typed: strict
# frozen_string_literal: true

class Components::Combobox < Components::Base
  register_element :el_autocomplete

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      clear_on_expand: T.nilable(T::Boolean),
      disabled: T::Boolean,
      input: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    form: nil,
    field: nil,
    clear_on_expand: nil,
    disabled: false,
    input: {},
    **attributes
  )
    super(**attributes)
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
      ) do |input_group|
        @inline_start_addon_block&.call(input_group)
        input_group.input(
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
        input_group.addon(align: :inline_end) do |addon|
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

      unless @disabled
        content_block.call
      end
    end
  end

  # == Interface ==

  sig do
    params(
      anchor: T.any(Symbol, T::Array[Symbol]),
      anchor_strategy: T.nilable(Symbol),
      attributes: T.untyped,
      content: T.proc.params(content: Components::Combobox::Content).void,
    ).void
  end
  def with_content(anchor: [ :bottom, :start ], anchor_strategy: nil, **attributes, &content)
    @content_block = ->() {
      render Components::Combobox::Content.new(
        anchor:,
        anchor_strategy:,
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
