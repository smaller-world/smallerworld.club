# typed: strict
# frozen_string_literal: true

require "pg_search"

module PgSearch::Features
  class TSearch
    module Websearch
      extend ActiveSupport::Concern
      extend T::Sig
      extend T::Helpers

      requires_ancestor { TSearch }

      sig { returns(Arel::Nodes::Node) }
      def tsquery
        if options[:websearch]
          return Arel::Nodes.build_quoted("") if query.blank?

          term_sql = normalize(Arel::Nodes.build_quoted(query))
          Arel::Nodes::NamedFunction
            .new("websearch_to_tsquery", [ dictionary, term_sql ])
        else
          super
        end
      end

      class_methods do
        extend T::Sig

        sig { returns(T::Array[Symbol]) }
        def valid_options
          super + [ :websearch ]
        end
      end
    end

    prepend Websearch
  end
end
