# typed: strict
# frozen_string_literal: true

module FormHelpers
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::HTML }

  # == Helpers ==

  sig do
    params(
      form: PhlexFormBuilder,
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      block: T.proc.params(field: Components::Button).void,
    ).void
  end
  def submit_button_for(
    form,
    variant: :default,
    size: :default,
    **attributes, &block
  )
    Components::Button(
      variant:,
      size:,
      **mix({ type: :submit }, attributes),
      &block
    )
  end

  sig do
    params(
      form: PhlexFormBuilder,
      method: Symbol,
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
      block: T.proc.params(field: Components::Field).void,
    ).void
  end
  def field_for(form, method, orientation: :vertical, invalid: false, **attributes, &block)
    Components::Field(
      form:,
      field: method,
      orientation:,
      invalid:,
      **attributes,
      &block
    )
  end

  sig do
    params(
      form: PhlexFormBuilder,
      method: Symbol,
      attributes: T.untyped,
      block: T.proc.params(field: Components::RadioGroup).void,
    ).void
  end
  def radio_group_for(form, method, **attributes, &block)
    Components::RadioGroup(form:, field: method, **attributes, &block)
  end
end
