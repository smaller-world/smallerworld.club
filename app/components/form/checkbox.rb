# typed: strict
# frozen_string_literal: true

class Components::Form
  class Checkbox < Superform::Rails::Components::Checkbox
    # == Component ==

    sig { override.void }
    def view_template
      if boolean?
        # Rails convention: hidden input ensures a value is sent even when unchecked
        input(name: dom.name, type: :hidden, value: "0")
        Components::Checkbox(
          value: "1",
          **attributes,
        )
      elsif collection?
        Components::Checkbox(
          value: dom.value,
          **attributes,
        )
      else
        Components::Checkbox(**attributes)
      end
    end

    protected

    # == Helpers ==

    sig { override.returns(T::Hash[Symbol, T.untyped]) }
    def field_attributes
      { **super, invalid: field.invalid? }
    end
  end
end
