# typed: true
# frozen_string_literal: true

class Components::Input < Components::Base
  include Phlex::Rails::Helpers::TextField

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      options: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, **options)
    @form = form
    @field = field
    @options = options
    super()
  end

  # == Component ==

  sig { override.void }
  def view_template
    options = mix({ data: { slot: "input" } }, @options)
    if @form && @field
      @form.text_field(@field, **with_invalid_aria(options))
    else
      text_field(**options)
    end
  end

  # == Helpers ==

  sig do
    params(options: T::Hash[Symbol, T.untyped])
      .returns(T::Hash[Symbol, T.untyped])
  end
  def with_invalid_aria(options)
    if field_has_errors?
      mix(options, aria: { invalid: true })
    else
      options
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
