# typed: strict
# frozen_string_literal: true

class Components::Form
  class FileInput < Superform::Rails::Components::Input
    # == Initialization ==

    sig do
      override.params(
        field: Field,
        direct_upload: T::Boolean,
        attributes: T.untyped,
      ).void
    end
    def initialize(field, direct_upload: true, **attributes)
      super(field, **attributes)
      @direct_upload = direct_upload
    end

    # == Configuration ==

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def field_attributes
      attributes = super
      attributes.delete(:type)
      attributes
    end

    # == Component ==

    sig { override.void }
    def view_template
      Components::FileInput(
        direct_upload: @direct_upload,
        **attributes,
      )
    end
  end
end
