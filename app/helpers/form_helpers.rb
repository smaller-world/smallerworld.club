# typed: strict
# frozen_string_literal: true

module FormHelpers
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::HTML }

  # == Helpers ==

  sig do
    params(
      form: PhlexRailsFormBuilder,
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.proc.params(field: Components::Button).void,
    ).void
  end
  def submit_button_for(
    form,
    variant: :default,
    size: :default,
    **attributes,
    &content
  )
    Components::Button(
      variant:,
      size:,
      **mix({ type: :submit }, attributes),
      &content
    )
  end

  sig do
    params(
      form: PhlexRailsFormBuilder,
      method: Symbol,
    ).returns(T.nilable(T::Array[String]))
  end
  def full_error_messages_for(form, method)
    if (object = form.object) &&
        object.is_a?(ActiveModel::Validations) &&
        (messages = object.errors.messages_for(method))
      messages
    end
  end

  sig do
    params(
      form: PhlexRailsFormBuilder,
      method: Symbol,
      messages: T.nilable(T::Array[String]),
      attributes: T.untyped,
    ).returns(T.untyped)
  end
  def field_error_for(form, method, messages: nil, **attributes)
    Components::FieldError(form:, field: method, messages:, **attributes)
  end

  sig do
    params(
      form: PhlexRailsFormBuilder,
      method: Symbol,
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(field: Components::Field).void,
    ).void
  end
  def field_for(form, method, orientation: :vertical, invalid: false, **attributes, &content)
    Components::Field(
      form:,
      field: method,
      orientation:,
      invalid:,
      **attributes,
      &content
    )
  end

  sig do
    params(
      form: PhlexRailsFormBuilder,
      method: Symbol,
      attributes: T.untyped,
      content: T.proc.params(field: Components::CheckboxGroup).void,
    ).void
  end
  def checkbox_group_for(form, method, **attributes, &content)
    Components::CheckboxGroup(form:, field: method, **attributes, &content)
  end

  sig do
    params(
      form: PhlexRailsFormBuilder,
      method: Symbol,
      toggleable: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(field: Components::RadioGroup).void,
    ).void
  end
  def radio_group_for(form, method, toggleable: false, **attributes, &content)
    render Components::RadioGroup.new(
      form:,
      field: method,
      toggleable:,
      **attributes,
      &content
    )
  end
end
