# typed: true
# frozen_string_literal: true

begin
  require "discard"
rescue LoadError
  return
end

module Tapioca
  module Dsl
    module Compilers
      class Discard < Compiler
        extend T::Sig
        include Helpers::ActiveRecordConstantsHelper

        ConstantType = type_member do
          { fixed: T.all(T.class_of(::ActiveRecord::Base), ::Discard::Model::ClassMethods) }
        end

        # == Methods ==

        sig { override.returns(T::Enumerable[T::Class[ActiveRecord::Base]]) }
        def self.gather_constants
          descendants_of(::ActiveRecord::Base).grep(::Discard::Model::ClassMethods)
        end

        sig { override.void }
        def decorate
          root.create_path(constant) do |model|
            # relation_methods_module = model
            #   .create_module(RelationMethodsModuleName)
            assoc_relation_methods_module = model
              .create_module(AssociationRelationMethodsModuleName)
            # generate_discard_include(
            #   relation_methods_module,
            #   RelationClassName,
            # )
            generate_discard_include(
              assoc_relation_methods_module,
              AssociationRelationClassName,
            )
          end
        end

        private

        # == Helpers ==

        sig do
          params(scope: RBI::Scope, return_type: String).void
        end
        def generate_discard_include(scope, return_type)
          scope.create_include("Discard::Model::ClassMethods")
        end
      end
    end
  end
end
