# typed: true
# frozen_string_literal: true

class Components::Textarea < Components::Input
  include Phlex::Rails::Helpers::TextAreaTag

  # == Component ==

  sig { override.void }
  def view_template
    attributes = mix(
      {
        class: "textarea",
        data: {
          slot: "textarea",
        },
      },
      @attributes,
    )
    if @form
      @form.textarea(@field, **normalize_attributes(with_invalid_aria(attributes)))
    else
      value = attributes.delete(:value)
      textarea_tag(@field, value, **normalize_attributes(attributes))
    end
  end
end
