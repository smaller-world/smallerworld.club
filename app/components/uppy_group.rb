# typed: strict
# frozen_string_literal: true

class Components::UppyGroup < Components::Input
  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      value: T.nilable(T::Enumerable[ActiveStorage::Blob]),
      required: T::Boolean,
      max_files: T.nilable(Integer),
      allowed_file_types: T.nilable(T::Array[String]),
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
    max_files: nil,
    allowed_file_types: nil,
    preview_fit: nil,
    dropzone_class: nil,
    **attributes
  )
    super(form:, field:, **attributes)
    @required = required
    @max_files = max_files
    @allowed_file_types = allowed_file_types
    @preview_fit = preview_fit
    @dropzone_class = dropzone_class
    @blobs = T.let(
      value&.to_a ||
        if form && field
          case (value = form.object.try(field))
          when Enumerable
            value.to_a
          when ActiveStorage::Attached::Many
            value.blobs.to_a
          end
        end ||
        [],
      T::Array[ActiveStorage::Blob],
    )
  end

  # == Component ==

  sig { override.void }
  def view_template
    root_element(
      :div,
      class: "uppy-group",
      data: {
        controller: "uppy-group",
        uppy_group_max_files_value: @max_files,
      },
    ) do
      template(data: { uppy_group_target: "dndTemplate" }) do
        dnd(
          data: {
            action: "uppy-dnd:ready->uppy-group#startNextUpload",
          },
        )
      end
      @blobs.each do |blob|
        dnd(value: blob)
      end
      if (n = remaining_files) && n > 0
        dnd
      end
    end
  end

  private

  # == Helpers ==

  sig { params(attributes: T.untyped).void }
  def dnd(**attributes)
    Components::UppyDnd(
      form: @form,
      field: @field,
      allowed_file_types: @allowed_file_types,
      preview_fit: @preview_fit,
      dropzone_class: @dropzone_class,
      multiple: true,
      max_files: remaining_files,
      clear_action: "uppy-group#removeDnd",
      **mix(
        {
          data: {
            uppy_group_target: "dnd",
            action: [
              "uppy-dnd:uploaded->uppy-group#update",
              "uppy-dnd:multiple-upload->uppy-group#addUploads",
              "uppy-group:upload->uppy-dnd#upload",
            ],
          },
        },
        attributes,
      ),
    )
  end

  sig { returns(T.nilable(Integer)) }
  def remaining_files
    if @max_files
      @max_files - @blobs.size
    end
  end
end
