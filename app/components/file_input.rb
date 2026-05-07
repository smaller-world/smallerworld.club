# typed: true
# frozen_string_literal: true

class Components::FileInput < Components::Input
  include Phlex::Rails::Helpers::FileField

  # == Component ==

  sig { override.void }
  def view_template
    attributes = mix({ class: "input", data: { slot: "input" } }, @attributes)
    if @form && @field
      @form.file_field(@field, **normalize_attributes(
        with_invalid_aria(attributes),
      ))
    else
      input(type: :file, **attributes)
    end
  end
end
