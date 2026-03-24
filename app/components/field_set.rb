# typed: true
# frozen_string_literal: true

class Components::FieldSet < Components::Base
  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(:div, data: { slot: "field-set" }, &content)
  end

  sig do
    params(variant: Symbol, attributes: T.untyped, content: T.proc.void).void
  end
  def legend(variant: :legend, **attributes, &content)
    legend(
      **mix(
        { data: { slot: "field-legend", variant: } },
        **attributes,
      ),
      &content
    )
  end
end
