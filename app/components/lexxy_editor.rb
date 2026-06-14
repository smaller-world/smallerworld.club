# typed: true
# frozen_string_literal: true

class Components::LexxyEditor < Components::Input
  extend Phlex::Rails::HelperMacros

  register_output_helper def rich_textarea_tag(...) = nil

  # == Component ==

  sig { override(allow_incompatible: true).void }
  def view_template
    value = @attributes.delete(:value) || form_value
    attributes = mix(
      {
        class: "lexxy-content",
        data: {
          controller: "lexxy-editor",
        },
        value:,
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

  private

  sig { returns(T.nilable(String)) }
  def form_value
    if @form && @field
      if (rich_text = @form.object.public_send(@field)) &&
          rich_text.is_a?(ActionText::EncryptedRichText)
        body = T.cast(rich_text.body, ActionText::Content)
        body.to_html
      end
    end
  end
end
