# typed: true
# frozen_string_literal: true

begin
  require "phlex"
rescue LoadError
  return
end

module Tapioca
  module Dsl
    module Compilers
      class PhlexCustomElements < Compiler
        extend T::Sig

        ConstantType = type_member { { fixed: T.class_of(::Phlex::HTML) } }

        sig { override.returns(T::Enumerable[T.class_of(::Phlex::HTML)]) }
        def self.gather_constants
          descendants_of(::Phlex::HTML).select do |klass|
            custom_elements(klass).any?
          end
        end

        sig { override.void }
        def decorate
          elements = self.class.custom_elements(constant)
          return if elements.empty?

          root.create_path(constant) do |scope|
            elements.each do |method_name, _tag|
              scope.create_method(
                method_name.to_s,
                parameters: [
                  create_kw_rest_param("attributes", type: "T.untyped"),
                  create_block_param(
                    "block",
                    type: "T.nilable(T.proc.void)",
                  ),
                ],
                return_type: "void",
              )
            end
          end
        end

        class << self
          extend T::Sig

          sig do
            params(klass: T.class_of(::Phlex::HTML))
              .returns(T::Hash[Symbol, T.untyped])
          end
          def custom_elements(klass)
            return {} unless klass.respond_to?(:__registered_elements__)

            own = klass.__registered_elements__
            parent = if (superclass = klass.superclass) &&
                superclass.respond_to?(:__registered_elements__)
              superclass.public_send(:__registered_elements__)
            else
              T.let({}, T::Hash[Symbol, T.untyped])
            end

            own.reject { |name, _| parent.key?(name) }
          end
        end
      end
    end
  end
end
