# typed: true
# frozen_string_literal: true

class Components::RichTextarea < Components::Base
  include Phlex::Rails::Helpers::RichTextArea

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      options: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, **options)
    @form = form
    @field = field
    @options = options
    super()
  end

  # == Component ==

  sig { override(allow_incompatible: true).void }
  def view_template
    options = mix(
      {
        # data: { slot: "textarea" },
        attachments: false,
        markdown: false,
      },
      @options,
    )
    if @form && @field
      @form.rich_textarea(@field, **options)
    else
      rich_textarea(**options)
    end
  end
end
