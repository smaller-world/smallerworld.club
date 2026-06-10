# typed: strict
# frozen_string_literal: true

class Components::FieldSet < Components::Base
  # == Configuration ==

  LEGEND_VARIANTS = [ :legend, :label ]

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      class: "field-set",
      data: {
        slot: "field-set",
      },
      &content
    )
  end

  sig do
    params(variant: Symbol, attributes: T.untyped, content: T.proc.void).void
  end
  def legend(variant: :legend, **attributes, &content)
    unless variant.in?(LEGEND_VARIANTS)
      raise InvalidParameter.new(parameter: :variant, value: variant)
    end

    super(
      **mix(
        {
          class: "field-legend",
          data: {
            slot: "field-legend",
            variant:,
          },
        },
        attributes,
      ),
      &content
    )
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def description(**attributes, &content)
    p(
      **mix(
        {
          class: "field-description",
          data: {
            slot: "field-description",
          },
        },
        attributes,
      ),
      &content
    )
  end

  sig do
    params(
      form: T.untyped,
      field: T.untyped,
      attributes: T.untyped,
      content: T.nilable(T.proc.params(group: Components::FieldGroup).void),
    ).void
  end
  def group(form: nil, field: nil, **attributes, &content)
    render Components::FieldGroup.new(form:, field:, **attributes, &content)
  end
end
