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
      class PhlexKit < Compiler
        extend T::Sig

        ConstantType = type_member { { fixed: Module } }

        sig { override.returns(T::Enumerable[Module]) }
        def self.gather_constants
          ObjectSpace.each_object(Module).select do |mod|
            next false if mod.singleton_class.ancestors.exclude?(::Phlex::Kit)
            next false if gem_module?(mod)

            true
          end
        end

        sig { override.void }
        def decorate
          root.create_path(constant) do |scope|
            kit_component_constants(constant).each do |name, component|
              generate_kit_method(scope, name, component)
            end
          end
        end

        class << self
          extend T::Sig

          private

          sig { params(mod: Module).returns(T::Boolean) }
          def gem_module?(mod)
            mod_name = mod.name
            return true if mod_name.nil?

            source_location = Object.const_source_location(mod_name)
            return true if source_location.nil?

            path = source_location.first.to_s
            return true if path.empty?

            !path.start_with?(Rails.root.to_s)
          end
        end

        private

        sig do
          params(mod: Module).returns(
            T::Array[[ String, T.class_of(::Phlex::SGML) ]],
          )
        end
        def kit_component_constants(mod)
          mod.constants(false).filter_map do |name| # rubocop:disable Sorbet/ConstantsFromStrings
            const = mod.const_get(name) # rubocop:disable Sorbet/ConstantsFromStrings
            next unless const.is_a?(Class) && const < ::Phlex::SGML
            next if T::AbstractUtils.abstract_module?(const)

            [ name.to_s, const ]
          end.sort_by(&:first)
        end

        sig do
          params(
            scope: RBI::Scope,
            name: String,
            component: T.class_of(::Phlex::SGML),
          ).void
        end
        def generate_kit_method(scope, name, component)
          parameters = build_parameters(component)
          block_type =
            "T.nilable(T.proc.params(instance: #{component.name}).void)"
          parameters << create_block_param("block", type: block_type)

          # Instance method: available inside Phlex templates via include
          scope.create_method(
            name,
            parameters:,
            return_type: "void",
          )

          # Singleton method: available as Components::Button(...)
          scope.create_method(
            name,
            parameters:,
            return_type: "void",
            class_method: true,
          )
        end

        sig do
          params(
            component: T.class_of(::Phlex::SGML),
          ).returns(T::Array[RBI::TypedParam])
        end
        def build_parameters(component)
          init = component.instance_method(:initialize)
          sig = T::Utils.signature_for_method(init)

          return [
            create_rest_param("args", type: "T.untyped"),
            create_kw_rest_param("kwargs", type: "T.untyped"),
          ] if sig.nil?

          ruby_params = sig.method.parameters

          ruby_params.filter_map do |kind, param_name|
            next if param_name.nil?

            type = resolve_param_type(sig, kind, param_name)

            case kind
            when :req
              create_param(param_name.to_s, type:)
            when :opt
              create_opt_param(param_name.to_s, type:, default: "T.unsafe(nil)")
            when :keyreq
              create_kw_param(param_name.to_s, type:)
            when :key
              create_kw_opt_param(param_name.to_s, type:, default: "T.unsafe(nil)")
            when :rest
              create_rest_param(param_name.to_s, type:)
            when :keyrest
              create_kw_rest_param(param_name.to_s, type:)
            end
          end
        end

        sig do
          params(
            sig: T.untyped,
            kind: Symbol,
            param_name: Symbol,
          ).returns(String)
        end
        def resolve_param_type(sig, kind, param_name)
          type = case kind
          when :req, :opt
            sig.arg_types.find { |name, _| name == param_name }&.last
          when :keyreq, :key
            sig.kwarg_types[param_name]
          when :rest
            sig.rest_type
          when :keyrest
            sig.keyrest_type
          end

          type&.to_s || "T.untyped"
        end
      end
    end
  end
end
