# typed: strict
# frozen_string_literal: true

class Components::Form
  class UppyGroup < Superform::Rails::Components::Input
    # == Initialization ==

    sig do
      override.params(
        field: Field,
        max_number_of_files: T.nilable(Integer),
        required: T::Boolean,
        allowed_file_types: T.nilable(T::Array[String]),
        crop_to_aspect_ratio: T.nilable(Numeric),
        preview_fit: T.nilable(Symbol),
        dropzone_class: T.nilable(String),
        attributes: T.untyped,
      ).void
    end
    def initialize(
      field,
      max_number_of_files: nil,
      required: false,
      allowed_file_types: nil,
      crop_to_aspect_ratio: nil,
      preview_fit: nil,
      dropzone_class: nil,
      **attributes
    )
      @max_number_of_files = max_number_of_files
      @required = required
      @allowed_file_types = allowed_file_types
      @crop_to_aspect_ratio = crop_to_aspect_ratio
      @preview_fit = preview_fit
      @dropzone_class = dropzone_class
      super(field, **attributes)
    end

    # == Configuration ==

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def field_attributes
      { id: dom.id, name: dom.array_name }
    end

    # == Component ==

    sig { override.void }
    def view_template
      Components::UppyGroup(
        value:,
        max_number_of_files: @max_number_of_files,
        required: @required,
        invalid: field.invalid?,
        allowed_file_types: @allowed_file_types,
        crop_to_aspect_ratio: @crop_to_aspect_ratio,
        preview_fit: @preview_fit,
        dropzone_class: @dropzone_class,
        **attributes,
      )
    end

    private

    # == Helpers ==

    sig { returns(T.nilable(T::Enumerable[ActiveStorage::Blob])) }
    def value
      value = field.value
      case value
      when ActiveStorage::Attached::Many
        value.blobs
      when Enumerable
        value
      else
        raise "Unexpected value: #{value}"
      end
    end
  end
end
