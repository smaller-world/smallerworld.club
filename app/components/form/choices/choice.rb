# typed: strict
# frozen_string_literal: true

class Components::Form
  module Choices
    class Choice
      extend T::Sig
      extend T::Generic

      Elem = type_member

      # == Initialization ==

      sig do
        params(
          component: Phlex::HTML,
          field: Field,
          value: T.any(String, T::Boolean),
          item: Elem,
          index: Integer,
          type: Symbol,
        ).void
      end
      def initialize(component:, field:, value:, item:, index:, type:)
        @component = T.let(component, Phlex::HTML)
        @field = T.let(field, Field)
        @value = T.let(value, T.any(String, T::Boolean))
        @item = T.let(item, Elem)
        @index = T.let(index, Integer)
        @type = T.let(type, Symbol)
      end

      # == Methods ==

      sig { returns(T.any(String, T::Boolean)) }
      attr_reader :value

      sig { returns(Elem) }
      attr_reader :item

      sig { returns(Integer) }
      attr_reader :index

      sig do
        params(
          attributes: T.untyped,
          content: T.nilable(T.proc.returns(T.anything)),
        ).void
      end
      def label(**attributes, &content)
        @component.render Label.new(
          @field,
          for: Superform::DOM.join(@field.dom.id, @index),
          **attributes,
        ) do
          if content
            yield
          else
            @item
          end
        end
      end

      sig { params(attributes: T.untyped).void }
      def input(**attributes)
        @component.render build_input(**attributes)
      end

      sig { params(attributes: T.untyped).returns(T.nilable(Phlex::HTML)) }
      def build_input(**attributes)
        case @type
        when :radio
          Radio.new(
            @field,
            value: @value,
            index: @index,
            **attributes,
          )
        when :checkbox
          Checkbox.new(
            @field,
            value: @value,
            index: @index,
            **attributes,
          )
        end
      end
    end
  end
end
