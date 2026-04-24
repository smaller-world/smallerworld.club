# typed: true
# frozen_string_literal: true

class Components::RichTextarea < Components::Input
  include Phlex::Rails::Helpers::RichTextArea

  # == Component ==

  sig { override(allow_incompatible: true).void }
  def view_template
    options = mix(
      {
        class: "lexxy-content",
        attachments: false,
        markdown: false,
      },
      @options,
    )
    if @form && @field
      @form.rich_textarea(@field, **with_invalid_aria(options))
    else
      rich_textarea(**options)
    end
  end
end
