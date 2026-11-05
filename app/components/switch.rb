# typed: strict
# frozen_string_literal: true

class Components::Switch < Components::Input
  include DeleteFrom

  # == Configuration ==

  SIZES = [ :default, :sm ].freeze

  # == Initialization ==

  sig do
    params(
      checked: T::Boolean,
      invalid: T::Boolean,
      size: Symbol,
      attributes: T.untyped,
    ).void
  end
  def initialize(checked: false, invalid: false, size: :default, **attributes)
    unless size.in?(SIZES)
      raise InvalidParameter.new(parameter: :size, value: size)
    end

    super(invalid:, **attributes)
    @checked = checked
    @size = size
  end

  # == Component ==

  sig { override.void }
  def view_template
    attributes = @attributes.dup
    input_attributes = delete_from(
      attributes,
      :id, :name, :value, :data, :readonly, :disabled, :required, :form
    )

    span(
      role: "switch",
      tabindex: input_attributes[:disabled] ? -1 : 0,
      **mix(
        {
          class: "switch group/switch peer",
          data: {
            controller: "checkable-proxy",
            checkable_proxy_intercept_enter_value: "false",
            slot: "switch",
            size: @size,
            checked: ("" if @checked),
            unchecked: ("" unless @checked),
            disabled: ("" if input_attributes[:disabled]),
            readonly: ("" if input_attributes[:readonly]),
            action: "click->checkable-proxy#forwardClick:prevent",
          },
          aria: {
            checked: @checked.to_s,
            disabled: ("true" if input_attributes[:disabled]),
            readonly: ("true" if input_attributes[:readonly]),
            required: ("true" if input_attributes[:required]),
            invalid: ("true" if @invalid),
          },
        },
        attributes,
      ),
    ) do
      span(class: "switch-thumb", data: { slot: "switch-thumb" })
    end
    input(
      type: :checkbox,
      tabindex: -1,
      checked: @checked,
      class: "visually-hidden",
      aria: { hidden: "true" },
      **input_attributes,
    )
  end
end
