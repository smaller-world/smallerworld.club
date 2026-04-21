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
    attributes = mix(
      { data: { slot: "textarea" }, value: @value },
      @attributes,
    )
    if @form && @field
      if @attributes.exclude?(:id)
        attributes[:id] = @form.field_id(@field)
      end
      if @attributes.exclude?(:name)
        attributes[:name] = @form.field_name(@field)
      end
    end

    textarea(**attributes)
  end
end
