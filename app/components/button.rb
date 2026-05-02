# typed: true
# frozen_string_literal: true

class Components::Button < Components::Base
  # == Configuration ==

  VARIANTS = [ :default, :outline, :secondary, :ghost, :destructive, :link ]
  SIZES = [ :default, :xs, :sm, :lg, :icon, :icon_xs, :icon_sm, :icon_lg ]
  ICON_ALIGNMENT = [ :inline_start, :inline_end ]

  # == Initialization ==

  sig { params(variant: Symbol, size: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, size: :default, **attributes)
    self.class.check_parameters!(variant:, size:)
    @variant = variant
    @size = size
    super(**attributes)
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :button,
      **mix(
        { data: { slot: "button" } },
        self.class.root_attributes(variant: @variant, size: @size),
      ),
      &content
    )
  end

  # == Interface ==

  sig { params(name: String, attributes: T.untyped).void }
  def inline_start_icon(name, **attributes)
    Icon(name, **mix({ data: { icon: "inline-start" } }, attributes))
  end

  sig { params(name: String, attributes: T.untyped).void }
  def inline_end_icon(name, **attributes)
    Icon(name, **mix({ data: { icon: "inline-end" } }, attributes))
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
        size: size.to_s.tr("_", "-"),
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

  private

  # == Helpers ==

  sig { params(name: String, align: String, attributes: T.untyped).void }
  def icon_addon(name, align:, **attributes)
    Icon(name, **mix({ data: { icon: align } }, attributes))
  end
end
