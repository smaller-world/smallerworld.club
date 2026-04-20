# typed: true
# frozen_string_literal: true

class Components::Textarea < Components::Base
  sig do
    params(
      form: T.nilable(ComponentFormBuilder),
      field: T.nilable(Symbol),
      value: T.nilable(String),
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, value: nil, **attributes)
    @form = form
    @field = field
    @value = T.let(
      case value
      when String
        value
      when nil
        if @form && @field
          @form.object.try(@field)
        end
      end,
      T.nilable(String),
    )
    super(**attributes)
  end

  # == Component ==

  sig { override(allow_incompatible: true).void }
  def view_template
    root_element(
      :textarea,
      data: { slot: "textarea" },
      **textarea_attributes,
      **({ value: @value } if @value),
    )
  end

  private

  # == Helpers ==

  sig { returns(T::Hash[Symbol, String]) }
  def textarea_attributes
    if @form && @field
      id = @form.field_id(@field)
      name = @form.field_name(@field)
    end
    { id:, name: }.compact
  end
end
