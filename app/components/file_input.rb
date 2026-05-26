# typed: strict
# frozen_string_literal: true

class Components::FileInput < Components::Input
  include Phlex::Rails::Helpers::FileFieldTag

  # == Component ==

  sig { override.void }
  def view_template
    attributes = mix({ class: "input", data: { slot: "input" } }, @attributes)
    if @form
      @form.file_field(@field, **normalize_attributes(
        with_invalid_aria(attributes),
      ))
    else
      file_field_tag(@field, **attributes)
    end
  end
end
