# typed: strict
# frozen_string_literal: true

class Components::Button < Components::Base
  # == Configuration ==

  VARIANTS = [ :default, :outline, :secondary, :ghost, :destructive, :link ].freeze
  SIZES = [ :default, :xs, :sm, :lg, :xl, :icon, :icon_xs, :icon_sm, :icon_lg ].freeze
  ICON_ALIGNMENT = [ :inline_start, :inline_end ].freeze

  # == Initialization ==

  sig { params(variant: Symbol, size: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, size: :default, **attributes)
    self.class.check_parameters!(variant:, size:)

    super(**attributes)
    @variant = variant
    @size = size
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :button,
      **mix(
        {
          type: ("button" if @element.nil? || @element == :button),
          data: { slot: "button" },
        },
        self.class.root_attributes(variant: @variant, size: @size),
      ),
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

  sig do
    params(variant: Symbol, size: Symbol)
      .returns(T::Hash[Symbol, T.untyped])
  end
  def self.root_attributes(variant: :default, size: :default)
    check_parameters!(variant:, size:)
    {
      class: "button group/button",
      data: {
        variant: variant.to_s,
        size:,
      },
    }
  end

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
