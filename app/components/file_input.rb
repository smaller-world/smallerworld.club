# typed: true
# frozen_string_literal: true

class Components::FileInput < Components::Input
  include Phlex::Rails::Helpers::FileField

  # == Component ==

  sig { override.void }
  def view_template
    options = mix({ class: "input", data: { slot: "input" } }, @options)
    if @form && @field
      @form.file_field(@field, **with_invalid_aria(options))
    else
      input(type: :file, **options)
    end
  end
end
