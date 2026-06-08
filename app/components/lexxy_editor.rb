# typed: true
# frozen_string_literal: true

class Components::LexxyEditor < Components::Input
  extend Phlex::Rails::HelperMacros

  register_output_helper def rich_textarea_tag(...) = nil

  # == Component ==

  sig { override(allow_incompatible: true).void }
  def view_template
    attributes = mix(
      {
        class: "lexxy-content",
        data: {
          controller: "lexxy-editor",
        },
      },
      @attributes,
    )

    if @form && @field
      @form.rich_textarea(@field, **normalize_attributes(
        with_invalid_aria(attributes),
      ))
    else
      rich_textarea_tag(@field, **normalize_attributes(attributes))
    end
  end
end
