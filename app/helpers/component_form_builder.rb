# typed: true
# frozen_string_literal: true

class ComponentFormBuilder < ActionView::Helpers::FormBuilder
  extend T::Sig
  include Phlex::Helpers

  # == Components ==

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      block: T.proc.params(field: Components::Button).void,
    ).void
  end
  def button(variant: :default, size: :default, **attributes, &block)
    Components::Button(
      variant:,
      size:,
      **mix({ type: :submit }, attributes),
      &block
    )
  end

  sig do
    params(
      name: T.nilable(Symbol),
      orientation: Symbol,
      invalid: T.nilable(TrueClass),
      options: T.untyped,
      block: T.proc.params(field: Components::Field).void,
    ).void
  end
  def field(name, orientation: :vertical, invalid: nil, options: {}, &block)
    Components::Field(
      form: self,
      field: name,
      orientation:,
      invalid:,
      options:,
      &block
    )
  end
end
