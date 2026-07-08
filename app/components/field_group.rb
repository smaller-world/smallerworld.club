# typed: strict
# frozen_string_literal: true

class Components::FieldGroup < Components::Base
  # == Component ==

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    slot = @attributes[:data]&.delete(:slot) || "field-group"
    root_element(
      :div,
      class: "field-group group/field-group",
      data: {
        slot:,
      },
      &content
    )
  end

  # == Interface ==

  sig do
    params(
      orientation: Symbol,
      invalid: T::Boolean,
      attributes: T.untyped,
      content: T.proc.params(field: Components::Field).void,
    ).void
  end
  def field(orientation: :vertical, invalid: false, **attributes, &content)
    render Components::Field.new(
      orientation:,
      invalid:,
      **attributes,
      &content
    )
  end
end
