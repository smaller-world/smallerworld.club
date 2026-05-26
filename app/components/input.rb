# typed: strict
# frozen_string_literal: true

class Components::Input < Components::Base
  include Phlex::Rails::Helpers::TextFieldTag

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, **attributes)
    super(**attributes)
    @form = form
    @field = field
  end

  # == Component ==

  sig { override.void }
  def view_template
    attributes = mix(
      {
        class: "input",
        data: {
          slot: "input",
        },
      },
      @attributes,
    )
    if @form
      @form.text_field(@field, **normalize_attributes(with_invalid_aria(attributes)))
    else
      value = attributes.delete(:value)
      text_field_tag(@field, value, **normalize_attributes(attributes))
    end
  end

  # == Helpers ==

  sig do
    params(attributes: T::Hash[Symbol, T.untyped])
      .returns(T::Hash[Symbol, T.untyped])
  end
  def with_invalid_aria(attributes)
    if field_has_errors?
      mix({ aria: { invalid: "true" } }, attributes)
    else
      attributes
    end
  end

  sig { returns(T::Boolean) }
  def field_has_errors?
    (object = @form&.object) &&
      @field &&
      object.respond_to?(:errors) &&
      (errors = object.errors) &&
      errors.respond_to?(:[]) &&
      errors[@field].present?
  end
end
