# typed: true
# frozen_string_literal: true

class Components::Input < Components::Base
  sig do
    params(
      form: T.nilable(ComponentFormBuilder),
      field: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, **attributes)
    @value = T.let(
      if attributes.include?(:value)
        attributes.delete(:value).try(:to_s)
      elsif form && field
        form.object.try(field)&.to_s
      end,
      T.nilable(T.any(String, Numeric)),
    )
    @form = form
    @field = field
    super(**attributes)
  end

  # == Component ==

  sig { override(allow_incompatible: true).void }
  def view_template
    attributes = mix(
      { data: { slot: "input" }, value: @value },
      @attributes,
    )
    if @form && @field
      if attributes.exclude?(:id)
        attributes[:id] = @form.field_id(@field)
      end
      if attributes.exclude?(:name)
        attributes[:name] = @form.field_name(@field)
      end
    end

    input(**attributes)
  end
end
