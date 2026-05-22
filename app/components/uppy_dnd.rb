# typed: true
# frozen_string_literal: true

class Components::UppyDnd < Components::Input
  include Phlex::Rails::Helpers::HiddenFieldTag

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      value: T.nilable(T.any(ActiveStorage::Blob, ActiveStorage::Attachment)),
      dropzone_class: T.nilable(String),
      attributes: T.untyped,
    )
      .void
  end
  def initialize(form: nil, field: nil, value: nil, dropzone_class: nil, **attributes)
    @dropzone_class = dropzone_class
    @blob = T.let(
      case value
      when ActiveStorage::Blob
        value
      when ActiveStorage::Attachment
        value.blob
      when nil
        if form && field
          case value = form.object.try(field)
          when ActiveStorage::Attached::One, ActiveStorage::Attachment
            value.blob
          when ActiveStorage::Blob
            value
          end
        end
      end,
      T.nilable(ActiveStorage::Blob),
    )
    super(form:, field:, **attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    input_options = {
      data: {
        uppy_dnd_target: "hiddenInput",
      },
    }

    root_element(
      :div,
      class: "flex flex-col",
      data: {
        controller: "uppy-dnd",
        uppy_dnd_direct_upload_url_value: rails_direct_uploads_path,
        uppy_dnd_preview_url_template_value: media_preview_path(":signed_id"),
        uppy_dnd_preview_signed_id_value: @blob&.signed_id,
        uppy_dnd_input_id_value: @form&.field_id(@field),
      },
    ) do
      div(
        class: [ "uppy-dnd-dropzone", @dropzone_class ],
        data: {
          uppy_dnd_target: "dropzone",
        },
      )
      if @form
        @form.hidden_field(@field, id: nil, value: @blob&.signed_id, **input_options)
      else
        hidden_field_tag(@field, @blob&.signed_id, id: nil, **input_options)
      end
      Components::Button(
        variant: :link,
        size: :sm,
        class: "uppy-dnd-clear",
        data: {
          action: "uppy-dnd#clear",
        },
      ) do
        "clear"
      end
    end
  end
end
