# typed: true
# frozen_string_literal: true

class Components::Textarea < Components::Input
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
    if @form && @field
      @form.textarea(@field, **with_invalid_aria(attributes))
    else
      textarea(**attributes)
    end
  end
end
