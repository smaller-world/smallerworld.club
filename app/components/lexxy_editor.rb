# typed: true
# frozen_string_literal: true

class Components::LexxyEditor < Components::Input
  include Phlex::Rails::Helpers::RichTextArea

  # == Component ==

  sig { override(allow_incompatible: true).void }
  def view_template
    attributes = mix(
      {
        class: "lexxy-content",
        attachments: false,
        markdown: false,
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
      rich_textarea(**normalize_attributes(attributes))
    end
  end
end
