# typed: strict
# frozen_string_literal: true

class Components::Form
  class Textarea < Superform::Rails::Components::Textarea
    # == Initialization ==

    sig { override.params(field: Field, attributes: T.untyped).void }
    def initialize(field, **attributes)
      super(field, **attributes)
      @attributes = T.let(@attributes, T::Hash[Symbol, T.untyped])
    end

    # == Component ==

    sig { override.params(content: T.nilable(T.proc.void)).void }
    def view_template(&content)
      Components::Textarea(**attributes) do
        if content
          yield
        else
          dom.value
        end
      end
    end

    # == Interface ==

    sig { override.returns(T::Hash[Symbol, T.untyped]) }
    def attributes
      super
    end

    protected

    # == Helpers ==

    sig { override.returns(T::Hash[Symbol, T.untyped]) }
    def field_attributes
      { **super, invalid: field.invalid? }
    end
  end
end
