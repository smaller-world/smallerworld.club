# typed: strict
# frozen_string_literal: true

class Components::Button < Components::Base
  # == Configuration ==

  VARIANTS = [ :default, :outline, :secondary, :ghost, :destructive, :link ].freeze
  SIZES = [ :default, :xs, :sm, :lg, :xl, :icon, :icon_xs, :icon_sm, :icon_lg ].freeze
  ICON_ALIGNMENT = [ :inline_start, :inline_end ].freeze

  # == Initialization ==

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(variant: :default, size: :default, invalid: false, **attributes)
    self.class.check_parameters!(variant:, size:)

    super(**attributes)
    @variant = variant
    @size = size
    @invalid = invalid
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    slot = @attributes[:data]&.delete(:slot) || "button"
    root_element(
      :button,
      class: "button group/button",
      aria: {
        invalid: ("true" if @invalid),
      },
      data: {
        slot:,
        variant: @variant,
        size: @size,
      },
      &content
    )
  end

  # == Interface ==

  sig { params(name: String, attributes: T.untyped).void }
  def inline_start_icon(name, **attributes)
    Icon(name, **mix({ data: { icon: :inline_start } }, attributes))
  end

  sig { params(name: String, attributes: T.untyped).void }
  def inline_end_icon(name, **attributes)
    Icon(name, **mix({ data: { icon: :inline_end } }, attributes))
  end

  # == Helpers ==

  sig { params(variant: Symbol, size: Symbol).void }
  def self.check_parameters!(variant:, size:)
    unless variant.in?(VARIANTS)
      raise InvalidParameter.new(parameter: :variant, value: variant)
    end
    unless size.in?(SIZES)
      raise InvalidParameter.new(parameter: :size, value: size)
    end
  end
end
