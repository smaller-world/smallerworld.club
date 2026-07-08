# typed: strict
# frozen_string_literal: true

class Components::FileInput < Components::Input
  # == Initialization ==

  sig { params(direct_upload: T::Boolean, invalid: T::Boolean, attributes: T.untyped).void }
  def initialize(direct_upload: true, invalid: false, **attributes)
    super(invalid:, **attributes)
    @direct_upload = direct_upload
  end

  # == Component ==

  sig { override.void }
  def view_template
    root_element(
      :input,
      type: "file",
      class: "input",
      data: {
        slot: "input",
        direct_upload_url: (rails_direct_uploads_path if @direct_upload),
      },
      aria: {
        invalid: ("true" if @invalid),
      },
    )
  end
end
