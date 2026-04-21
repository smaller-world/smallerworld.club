# typed: true
# frozen_string_literal: true

class Components::Textarea < Components::Input
  include Phlex::Rails::Helpers::TextArea

  # == Component ==

  sig { override.void }
  def view_template
    options = mix({ data: { slot: "textarea" } }, @options)
    if @form && @field
      @form.textarea(@field, **options)
    else
      textarea(**options)
    end
  end
end
