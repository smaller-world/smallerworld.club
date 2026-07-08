# typed: strict
# frozen_string_literal: true

class Components::Form
  class Radios < Superform::Rails::Components::Radios
    extend T::Generic

    Elem = type_member

    # == Initialization ==

    sig do
      params(
        field: Field,
        options: T.any(T::Array[[ String, Elem ]], T.all(T::Enumerable[Elem], Object)),
        toggleable: T::Boolean,
        attributes: T.untyped,
      ).void
    end
    def initialize(field, options: [], toggleable: false, **attributes)
      super(field, options:, **attributes)
      @field = T.let(@field, Field)
      @options = T.let(@options, T.all(T::Enumerable[Elem], Object))
      @toggleable = toggleable
    end

    # == Component ==

    sig do
      params(
        content: T.nilable(
          T.proc.params(choice: Choices::Choice[Elem]).returns(T.untyped),
        ),
      ).returns(T.untyped)
    end
    def view_template(&content)
      Components::RadioGroup(**@attributes) do
        choices.each do |choice|
          if block_given?
            yield(choice)
          else
            Components::Field(
              orientation: :horizontal,
              invalid: field.invalid?,
            ) do |field|
              choice.input(toggleable: @toggleable)
              field.label(for: Superform::DOM.join(dom.id, choice.index))
            end
          end
        end
      end
    end

    private

    # == Helpers ==

    sig { override.returns(T::Enumerable[Choices::Choice[Elem]]) }
    def choices
      Choices.from_options(@options, component: self, field:, type: :radio)
    end
  end
end
