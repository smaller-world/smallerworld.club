# typed: strict
# frozen_string_literal: true

class Components::UppyDnd < Components::Input
  include Phlex::Rails::Helpers::HiddenFieldTag

  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      value: T.nilable(T.any(ActiveStorage::Blob, ActiveStorage::Attachment)),
      required: T::Boolean,
      multiple: T::Boolean,
      allowed_file_types: T.nilable(T::Array[String]),
      crop_to_aspect_ratio: T.nilable(Numeric),
      clear_action: T.nilable(String),
      preview_fit: T.nilable(Symbol),
      dropzone_class: T.nilable(String),
      attributes: T.untyped,
    )
      .void
  end
  def initialize(
    form: nil,
    field: nil,
    value: nil,
    required: false,
    multiple: false,
    allowed_file_types: nil,
    crop_to_aspect_ratio: nil,
    clear_action: nil,
    preview_fit: nil,
    dropzone_class: nil,
    **attributes
  )
    @required = required
    @multiple = multiple
    @allowed_file_types = allowed_file_types
    @crop_to_aspect_ratio = crop_to_aspect_ratio
    @clear_action = clear_action
    @preview_fit = preview_fit
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
      multiple: @multiple,
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
        uppy_dnd_required_value: @required,
        uppy_dnd_multiple_value: @multiple,
        uppy_dnd_allowed_file_types_value: @allowed_file_types&.join(","),
        uppy_dnd_crop_to_aspect_ratio_value: @crop_to_aspect_ratio,
      },
    ) do
      div(
        class: [ "uppy-dnd-dropzone", @dropzone_class ],
        data: {
          uppy_dnd_target: "dropzone",
        },
        style: ("--preview-fit: #{@preview_fit};" if @preview_fit),
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
          action: [ "uppy-dnd#clear", @clear_action ],
        },
      ) do
        "clear"
      end

      if @crop_to_aspect_ratio
        Components::Dialog(
          data: {
            uppy_dnd_target: "imageEditorDialog",
            action: [
              "uppy-dnd:open-image-editor->dialog#open",
              "open->uppy-dnd#selectEditorImage",
              "cancel->uppy-dnd#cancelImageEdit",
            ],
          },
        ) do |dialog|
          dialog.with_content(
            show_close_button: false,
            panel: {
              class: "gap-4 p-0",
            },
          ) do |content|
            div(
              class: "uppy-dnd-cropper",
              data: {
                uppy_dnd_target: "imageEditor",
              },
            )
            div(class: "border-t-border flex justify-center gap-2 p-4") do
              content.close_button(
                variant: :default,
                size: :sm,
                data: {
                  action: "uppy-dnd#saveImageEdit",
                },
              ) do |button|
                button.inline_start_icon("huge/image-crop")
                span { "crop and continue" }
              end
              content.close_button(
                size: :sm,
                data: {
                  action: "uppy-dnd#cancelImageEdit",
                },
              ) do
                "cancel"
              end
            end
          end
        end
      end
    end
  end
end
