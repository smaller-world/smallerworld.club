# typed: strict
# frozen_string_literal: true

class Components::Form
  class Checkboxes < Superform::Rails::Components::Checkboxes
    extend T::Generic

    Elem = type_member

    # == Initialization ==

    sig do
      params(
        field: Field,
        options: T.all(T::Enumerable[Elem], Object),
        include_hidden: T::Boolean,
        attributes: T.untyped,
      ).void
    end
    def initialize(field, options: [], include_hidden: true, **attributes)
      super(field, options:, **attributes)
      @field = T.let(@field, Field)
      @options = T.let(@options, T.all(T::Enumerable[Elem], Object))
      @include_hidden = include_hidden
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
      Components::CheckboxGroup(**@attributes) do
        if @include_hidden
          render @field.hidden(name: dom.array_name, value: nil)
        end

        choices.each do |choice|
          if block_given?
            yield(choice)
          else
            Components::Field(
              orientation: :horizontal,
              invalid: field.invalid?,
            ) do |field|
              choice.input
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
      Choices.from_options(@options, component: self, field:, type: :checkbox)
    end
  end
end
