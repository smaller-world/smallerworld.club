# typed: true
# frozen_string_literal: true

class Components::FileInput < Components::Base
  sig do
    params(
      form: T.nilable(ComponentFormBuilder),
      field: T.nilable(Symbol),
      direct_upload: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, direct_upload: true, **attributes)
    super(**attributes)
    @form = form
    @field = field
    @direct_upload = direct_upload
  end

  # == Component ==

  sig { override(allow_incompatible: true).void }
  def view_template
    Components::Input(
      form: @form,
      field: @field,
      type: :file,
      value: nil,
      **mix(
        {
          data: ({
            direct_upload_url: rails_direct_uploads_path,
          } if @direct_upload),
        },
        @attributes,
      ),
    )
  end
end
