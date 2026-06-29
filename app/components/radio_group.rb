# typed: strict
# frozen_string_literal: true

class Components::RadioGroup < Components::Base
  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      toggleable: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, toggleable: false, **attributes)
    super(**attributes)
    @toggleable = toggleable
    @form = form
    @field = field
  end

  # == Component ==

  sig { override.params(block: T.proc.void).void }
  def view_template(&block)
    root_element(
      :div,
      class: "radio-group",
      data: {
        slot: "radio-group",
      },
      &block
    )
  end

  # == Interface ==

  sig do
    params(
      id: T.nilable(String),
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(field: Components::Field).void,
    ).void
  end
  def field(
    id: nil,
    orientation: :vertical,
    invalid: false,
    **attributes,
    &content
  )
    render Components::Field.new(
      form: @form,
      field: @field,
      id:,
      orientation:,
      invalid:,
      **attributes,
      &content
    )
  end

  sig do
    params(
      value: T.any(Symbol, String, Enumerize::Value),
      attributes: T.untyped,
      content: T.proc.params(label: Components::RadioGroup::FieldLabel).void,
    ).void
  end
  def field_label_for(value, **attributes, &content)
    namespace = @field || self.namespace
    if @form
      input_id = @form.field_id(namespace, value)
      label_id = @form.field_id(namespace, value, :label)
    else
      input_id = field_id(namespace, value)
      label_id = field_id(namespace, value, :label)
    end
    attributes = {
      **attributes,
      for: input_id,
    }
    render Components::RadioGroup::FieldLabel.new(
      radio_group: self,
      form: @form,
      field: @field,
      id: label_id,
      **attributes,
      &content
    )
  end

  # == Helpers ==

  sig { returns(String) }
  def namespace
    @namespace ||= T.let(
      if @form && @field
        @form.field_id(@field)
      elsif @field
        field_id(@field)
      else
        SecureRandom.uuid
      end,
      T.nilable(String),
    )
  end

  sig { returns(T::Boolean) }
  def toggleable?
    @toggleable
  end
end
