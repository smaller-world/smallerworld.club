# typed: strict
# frozen_string_literal: true

class Components::Form
  class Radio < Superform::Rails::Components::Radio
    # == Initialization ==

    sig do
      params(
        field: Field,
        value: T.nilable(T.any(String, T::Boolean)),
        index: T.nilable(Integer),
        toggleable: T::Boolean,
        attributes: T.untyped,
      ).void
    end
    def initialize(field, value:, index:, toggleable: false, **attributes)
      super(field, **T.unsafe({ value:, index:, **attributes }))
      @toggleable = toggleable
    end

    # == Component ==

    sig { override.void }
    def view_template
      Components::RadioGroupItem(
        toggleable: @toggleable,
        **attributes,
      )
    end

    protected

    # == Helpers ==

    sig { override.returns(T::Hash[Symbol, T.untyped]) }
    def field_attributes
      { **super, invalid: field.invalid? }
    end
  end
end
