# typed: true
# frozen_string_literal: true

class Components::Button < Components::Base
  # == Configuration ==

  sig { params(variant: Symbol, size: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, size: :default, **attributes)
    super(**attributes)
    @variant = variant
    @size = size
  end

  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(:button, **root_attributes, &content)
  end

  # == Helpers ==

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def root_attributes
    {
      class: "group/button",
      data: {
        slot: "button",
        variant: @variant,
        size: @size,
      },
    }
  end
end
