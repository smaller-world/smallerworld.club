# typed: strict
# frozen_string_literal: true

class Components::CheckboxGroup < Components::FieldGroup
  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, **attributes)
    super(**mix({ data: { slot!: "checkbox-group" } }, attributes))
    @form = form
    @field = field
  end

  sig do
    params(
      value: T.any(Symbol, String, Enumerize::Value),
      attributes: T.untyped,
      content: T.proc.params(label: Components::CheckboxGroup::FieldLabel).void,
    ).void
  end
  def field_label_for(value, **attributes, &content)
    value = value.to_s
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
    render Components::CheckboxGroup::FieldLabel.new(
      checkbox_group: self,
      form: @form,
      field: @field,
      id: label_id,
      **attributes,
      &content
    )
  end
end
