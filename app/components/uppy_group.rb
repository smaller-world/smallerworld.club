# typed: strict
# frozen_string_literal: true

class Components::UppyGroup < Components::Input
  include DeleteFrom

  # == Initialization ==

  sig do
    params(
      value: T.nilable(T::Enumerable[ActiveStorage::Blob]),
      max_number_of_files: T.nilable(Integer),
      required: T::Boolean,
      invalid: T::Boolean,
      preview_fit: T.nilable(Symbol),
      allowed_file_types: T.nilable(T::Array[String]),
      dropzone_class: T.nilable(String),
      attributes: T.untyped,
    )
      .void
  end
  def initialize(
    value: nil,
    max_number_of_files: nil,
    required: false,
    invalid: false,
    preview_fit: nil,
    allowed_file_types: nil,
    dropzone_class: nil,
    **attributes
  )
    input_id = attributes.delete(:id)
    input_attributes = delete_from(attributes, :name)
    super(invalid:, **attributes)

    @max_number_of_files = max_number_of_files
    @value = value
    @required = required
    @preview_fit = preview_fit
    @allowed_file_types = allowed_file_types
    @dropzone_class = dropzone_class

    @input_id = T.let(input_id, T.nilable(String))
    @input_attributes = T.let(input_attributes, T::Hash[Symbol, T.untyped])
  end

  # == Component ==

  sig { override.void }
  def view_template
    div(**mix(
      {
        class: "uppy-group",
        data: {
          controller: "uppy-group",
          action: [
            "uppy:uploaded->uppy-group#update",
            "uppy:multiple-upload->uppy-group#addFilesToUpload",
          ],
          required: @required,
          uppy_group_max_number_of_files_value: @max_number_of_files,
          uppy_group_input_id_value: @input_id,
        },
      },
      @attributes,
    )) do
      template(data: { uppy_group_target: "itemTemplate" }) do
        item(data: {
          action: "uppy-group:request-upload->uppy#uploadExternalFile",
        })
      end

      @value&.each do |blob|
        item(value: blob)
      end

      remaining_files = self.remaining_files
      if !remaining_files || remaining_files > 0
        item(id: @input_id)
      end
    end
  end

  # == Interface ==

  sig { returns(T.nilable(Integer)) }
  def remaining_files
    if @max_number_of_files && @value
      @max_number_of_files - @value.count
    end
  end

  private

  # == Helpers ==

  sig { params(attributes: T.untyped).void }
  def item(**attributes)
    Components::Uppy(
      group: self,
      preview_fit: @preview_fit,
      allowed_file_types: @allowed_file_types,
      **mix(
        {
          dropzone_class: @dropzone_class,
          data: {
            uppy_group_target: "item",
            slot: "uppy-group-item",
            action: [
              "uppy-group:request-allow-item-multiple-uploads->uppy#allowMultipleUploads",
              "uppy-group:request-disallow-item-multiple-uploads->uppy#disallowMultipleUploads",
            ],
          },
        },
        @input_attributes,
        attributes,
      ),
    ) do |uppy|
      uppy.with_clear_button(data: { action: "uppy-group#removeItem" }) do
        "remove"
      end
    end
  end
end
