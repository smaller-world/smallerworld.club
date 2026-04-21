# typed: true
# frozen_string_literal: true

class Components::FileInput < Components::Input
  include Phlex::Rails::Helpers::FileField

  # == Component ==

  sig { override.void }
  def view_template
    options = mix({ data: { slot: "input" } }, @options)
    if @form && @field
      @form.file_field(@field, **options)
    else
      file_field(**options)
    end
  end
end
