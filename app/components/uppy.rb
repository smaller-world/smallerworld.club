# typed: strict
# frozen_string_literal: true

class Components::Uppy < Components::Input
  include DeleteFrom

  # == Initialization ==

  sig do
    params(
      group: T.nilable(Components::UppyGroup),
      value: T.nilable(ActiveStorage::Blob),
      required: T::Boolean,
      invalid: T::Boolean,
      allowed_file_types: T.nilable(T::Array[String]),
      crop_to_aspect_ratio: T.nilable(Numeric),
      preview_fit: T.nilable(Symbol),
      dropzone_class: T.nilable(String),
      attributes: T.untyped,
    )
      .void
  end
  def initialize(
    group: nil,
    value: nil,
    required: false,
    invalid: false,
    allowed_file_types: nil,
    crop_to_aspect_ratio: nil,
    preview_fit: nil,
    dropzone_class: nil,
    **attributes
  )
    super(invalid:, **attributes)
    @group = group
    @value = value
    @required = required
    @allowed_file_types = allowed_file_types
    @crop_to_aspect_ratio = crop_to_aspect_ratio
    @preview_fit = preview_fit
    @dropzone_class = dropzone_class
    @clear_button_block = T.let(nil, T.nilable(T.proc.void))
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    vanish(&content)

    attributes = @attributes
    input_id = attributes.delete(:id)
    input_attributes = delete_from(attributes, :name)

    div(**mix(
      {
        class: "uppy",
        data: {
          required: @required,
          controller: "uppy",
          uppy_direct_upload_url_value: rails_direct_uploads_path,
          uppy_preview_url_template_value: media_preview_path(":signed_id"),
          uppy_preview_signed_id_value: @value&.signed_id,
          uppy_multiple_value: (@group.remaining_files != 1 if @group),
          uppy_allowed_file_types_value: @allowed_file_types&.join(","),
          uppy_crop_to_aspect_ratio_value: @crop_to_aspect_ratio,
          uppy_input_id_value: input_id,
        },
      },
      attributes,
    )) do
      div(
        class: class_names("uppy-dropzone", @dropzone_class),
        data: {
          slot: "uppy-dropzone",
          uppy_target: "dropzone",
        },
        aria: {
          invalid: ("true" if @invalid),
        },
        style: ("--preview-fit: #{@preview_fit}" if @preview_fit),
      )
      input(
        type: "hidden",
        value: @value&.signed_id,
        **mix(
          { data: { uppy_target: "hiddenInput" } },
          input_attributes,
        ),
      )
      if @clear_button_block
        @clear_button_block.call
      else
        clear_button
      end

      if @crop_to_aspect_ratio
        cropper_dialog
      end
    end
  end

  # == Interface ==

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.params(button: Components::Button).returns(T.anything)),
    ).void
  end
  def with_clear_button(variant: :link, size: :sm, **attributes, &content)
    @clear_button_block = ->() {
      clear_button(variant:, size:, **attributes, &content)
    }
  end

  private

  # == Helpers ==

  sig do
    params(
      variant: Symbol,
      size: Symbol,
      attributes: T.untyped,
      content: T.nilable(T.proc.params(button: Components::Button).returns(T.anything)),
    ).void
  end
  def clear_button(variant: :link, size: :sm, **attributes, &content)
    Components::Button(
      type: :button,
      variant: :link,
      size: :sm,
      **mix(
        {
          class: "uppy-clear",
          data: {
            slot: "uppy-clear",
            action: "uppy#clear",
          },
        },
        attributes,
      ),
    ) do |button|
      if block_given?
        yield(button)
      else
        "clear"
      end
    end
  end

  sig { void }
  def cropper_dialog
    Components::Dialog(
      data: {
        action: "cancel->uppy#cancelCrop",
      },
    ) do |dialog|
      dialog.with_content(show_close_button: false) do |dialog_content|
        div(class: "uppy-cropper", data: {
          uppy_target: "cropper",
          action: "uppy:request-open-cropper->dialog#open",
        })
        dialog_content.footer(class: "flex-row justify-center") do
          dialog_content.close_button(
            variant: :default,
            size: :sm,
            data: { action: "uppy#saveCrop" },
          ) do |button|
            button.inline_start_icon("huge/image-crop")
            span { "crop and continue" }
          end
          dialog_content.close_button(
            size: :sm,
            data: { action: "uppy#cancelCrop" },
          ) do
            "cancel"
          end
        end
      end
    end
  end
end
