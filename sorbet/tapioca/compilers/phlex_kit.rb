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
          all_modules.select do |mod|
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
          # Resolve the component's Sorbet type members. Free members (e.g.
          # `Elem = type_member`) become fresh method type parameters so that a
          # generic component produces a generic kit method; fixed members (e.g.
          # `Elem = type_member { { fixed: Foo } }`) are replaced with their
          # concrete type since the class is not parameterizable.
          substitutions, free_type_args = type_parameter_substitutions(component)

          parameters = build_parameters(component, substitutions)

          instance_type = component.name.to_s
          unless free_type_args.empty?
            instance_type = "#{instance_type}[#{free_type_args.join(", ")}]"
          end
          block_type = "T.proc.params(instance: #{instance_type}).void"
          # If the component's `view_template` requires a block (its block
          # parameter — the `&` parameter, sometimes named `&content` — is typed
          # non-nilable), the kit helper's `&content` must also be non-nilable.
          # Otherwise the block is optional.
          unless view_template_requires_block?(component)
            block_type = as_nilable_type(block_type)
          end
          parameters << create_block_param("content", type: block_type)
          comments = source_comments(component)

          # Instance method: available inside Phlex templates via include
          scope.create_method(
            name,
            parameters:,
            return_type: "void",
            comments:,
          )

          # Singleton method: available as Components::Button(...)
          scope.create_method(
            name,
            parameters:,
            return_type: "void",
            class_method: true,
            comments:,
          )
        end

        # Detects whether the component's `view_template` requires a block. Phlex
        # wraps every `view_template` so its Ruby parameters always report a
        # `:block` param; the meaningful signal is the Sorbet signature's block
        # type. A non-nilable block type (e.g. `T.proc...`) means the block is
        # required; a nilable one (`T.nilable(T.proc...)`) or a missing block
        # type means it is optional.
        sig { params(component: T.class_of(::Phlex::SGML)).returns(T::Boolean) }
        def view_template_requires_block?(component)
          return false unless component.method_defined?(:view_template) ||
            component.private_method_defined?(:view_template)

          sig = T::Utils.signature_for_method(
            component.instance_method(:view_template),
          )
          block_type = sig&.block_type
          return false if block_type.nil?

          nil_type = T::Utils.coerce(NilClass)
          if block_type.is_a?(T::Types::Union)
            return block_type.types.none?(nil_type)
          end

          true
        end

        sig do
          params(component: T.class_of(::Phlex::SGML)).returns(T::Array[RBI::Comment])
        end
        def source_comments(component)
          location = Object.const_source_location(T.must(component.name))
          return [] unless location

          path, line = location
          relative_path = Pathname.new(path).relative_path_from(Rails.root).to_s
          [ RBI::Comment.new("workspace://#{relative_path}:#{line}") ]
        end

        # Inspects the component's Sorbet type members and returns:
        #   1. a substitution map from type member name (e.g. `"Elem"`) to the
        #      string to replace references with — a fresh method type parameter
        #      (e.g. `"T.type_parameter(:U)"`) for free members, or the concrete
        #      type (e.g. `"::Foo"`) for fixed members.
        #   2. the ordered list of method type parameters for free members, used
        #      to index the component's generic type (e.g. `Foo[T.type_parameter(:U)]`).
        # Both are empty for non-generic components.
        sig do
          params(component: T.class_of(::Phlex::SGML))
            .returns([ T::Hash[String, String], T::Array[String] ])
        end
        def type_parameter_substitutions(component)
          type_variables =
            Tapioca::Runtime::GenericTypeRegistry.lookup_type_variables(component)
          return [ {}, [] ] if type_variables.nil?

          substitutions = {}
          free_type_args = []

          type_variables.each do |type_variable|
            next if type_variable.type ==
              Tapioca::TypeVariableModule::Type::HasAttachedClass

            name = type_variable.name
            next if name.nil?

            if type_variable.fixed?
              fixed = type_variable.send(:bounds).fetch(:fixed)
              substitutions[name] = T::Utils.coerce(fixed).to_s
            else
              type_parameter = "T.type_parameter(:#{("U".ord + free_type_args.length).chr})"
              substitutions[name] = type_parameter
              free_type_args << type_parameter
            end
          end

          [ substitutions, free_type_args ]
        end

        # Rewrites a resolved type string, replacing references to the
        # component's type members with their method type parameters.
        sig do
          params(type: String, substitutions: T::Hash[String, String]).returns(String)
        end
        def apply_type_parameter_substitutions(type, substitutions)
          substitutions.reduce(type) do |result, (name, replacement)|
            result.gsub(/\b#{Regexp.escape(name)}\b/, replacement)
          end
        end

        sig do
          params(
            component: T.class_of(::Phlex::SGML),
            substitutions: T::Hash[String, String],
          ).returns(T::Array[RBI::TypedParam])
        end
        def build_parameters(component, substitutions = {})
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
            type = apply_type_parameter_substitutions(type, substitutions)

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
