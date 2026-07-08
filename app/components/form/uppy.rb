# typed: strict
# frozen_string_literal: true

class Components::Form
  class Uppy < Superform::Rails::Components::Field
    # == Initialization ==

    sig do
      override.params(
        field: Field,
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
      required: false,
      allowed_file_types: nil,
      crop_to_aspect_ratio: nil,
      preview_fit: nil,
      dropzone_class: nil,
      **attributes
    )
      @required = required
      @allowed_file_types = allowed_file_types
      @crop_to_aspect_ratio = crop_to_aspect_ratio
      @preview_fit = preview_fit
      @dropzone_class = dropzone_class
      super(field, **attributes)
    end

    # == Component ==

    sig { override.void }
    def view_template
      Components::Uppy(
        required: @required,
        allowed_file_types: @allowed_file_types,
        crop_to_aspect_ratio: @crop_to_aspect_ratio,
        preview_fit: @preview_fit,
        dropzone_class: @dropzone_class,
        **attributes,
      )
    end

    protected

    # == Helpers ==

    sig { override.returns(T::Hash[Symbol, T.untyped]) }
    def field_attributes
      {
        id: dom.id,
        name: dom.name,
        value:,
        invalid: field.invalid?,
      }
    end

    private

    # == Helpers ==

    sig { returns(T.nilable(ActiveStorage::Blob)) }
    def value
      value = field.value
      case value
      when ActiveStorage::Blob
        value
      when ActiveStorage::Attached::One
        value.blob
      else
        raise "Unexpected value: #{value}"
      end
    end
  end
end
