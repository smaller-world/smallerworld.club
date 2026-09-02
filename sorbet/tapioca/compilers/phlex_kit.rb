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

          # Mirror the `view_template`'s block onto the kit helper's `&content`:
          #   - no block on `view_template`      -> no block on the kit helper
          #   - nilable block on `view_template` -> nilable block on the kit helper
          #   - required block on `view_template`-> required block on the kit helper
          # When `view_template`'s block declares its own params (e.g. it yields
          # a `Components::Dialog`), the kit helper yields those same params;
          # otherwise it yields the component instance itself.
          block_info = view_template_block(component)
          if block_info
            nilable, proc_type = block_info
            proc_params = proc_type.arg_types
            block_params = if proc_params.empty?
              "instance: #{instance_type}"
            else
              proc_params.map do |pname, ptype|
                resolved =
                  apply_type_parameter_substitutions(ptype.to_s, substitutions)
                "#{pname}: #{resolved}"
              end.join(", ")
            end
            block_type = "T.proc.params(#{block_params}).void"
            block_type = as_nilable_type(block_type) if nilable
            parameters << create_block_param("content", type: block_type)
          end

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

        # Inspects the component's `view_template` block. Phlex wraps every
        # `view_template` so its Ruby parameters always report a `:block` param;
        # the meaningful signal is the Sorbet signature's block type. Returns
        # `nil` when there is no block type (the kit helper should accept no
        # block), otherwise `[nilable, proc_type]` where `nilable` is whether
        # the block is optional (a `T.nilable(T.proc...)` union) and `proc_type`
        # is the `T::Types::Proc` describing the block's params.
        sig do
          params(component: T.class_of(::Phlex::SGML))
            .returns(T.nilable([ T::Boolean, T::Types::Proc ]))
        end
        def view_template_block(component)
          return unless component.method_defined?(:view_template) ||
            component.private_method_defined?(:view_template)

          sig = T::Utils.signature_for_method(
            component.instance_method(:view_template),
          )
          block_type = sig&.block_type
          return if block_type.nil?

          if block_type.is_a?(T::Types::Union)
            proc_type = block_type.types.find { |t| t.is_a?(T::Types::Proc) }
            return if proc_type.nil?

            nil_type = T::Utils.coerce(NilClass)
            nilable = block_type.types.any?(nil_type)
            return [ nilable, T.cast(proc_type, T::Types::Proc) ]
          end

          return [ false, block_type ] if block_type.is_a?(T::Types::Proc)

          nil
        end

        sig do
          params(component: T.class_of(::Phlex::SGML)).returns(T::Array[RBI::Comment])
        end
        def source_comments(component)
          location = Object.const_source_location(T.must(component.name))
          return [] unless location

          path, line = location
          relative_path = Pathname.new(path).relative_path_from(Rails.root).to_s
          [ RBI::Comment.new("source://#{relative_path}:#{line}") ]
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
