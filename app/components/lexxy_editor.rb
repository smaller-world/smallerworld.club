# typed: true
# frozen_string_literal: true

class Components::LexxyEditor < Components::Input
  extend Phlex::Rails::HelperMacros
  include NormalizeAttributes

  register_output_helper def rich_textarea_tag(...) = nil

  # == Component ==

  sig { override(allow_incompatible: true).void }
  def view_template
    attributes = @attributes
    name = attributes.delete(:name)
    value = attributes.delete(:value)
    rich_textarea_tag(name, value, **normalize_attributes(mix(
      {
        class: "lexxy-content",
        data: {
          controller: "lexxy-editor",
        },
        aria: {
          invalid: ("true" if @invalid),
        },
      },
      attributes,
    )))
  end
end
