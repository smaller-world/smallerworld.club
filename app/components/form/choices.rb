# typed: strict
# frozen_string_literal: true

class Components::Form
  module Choices
    extend T::Sig

    sig do
      type_parameters(:U)
        .params(
          options: T.all(T::Enumerable[T.type_parameter(:U)], Object),
          field: Field,
          component: Phlex::HTML,
          type: Symbol,
        )
        .returns(T::Enumerable[Choice[T.type_parameter(:U)]])
    end
    def self.from_options(options, field:, component:, type:)
      options.map.with_index do |option, index|
        value, item = case option
        in id, value
          [ id, value ]
        in value
          if value.is_a?(ActiveRecord::Base)
            primary_key = if options.is_a?(ActiveRecord::Relation)
              options.primary_key
            else
              value.class.primary_key
            end
            id = value[primary_key]
            [ id, value ]
          else
            [ option, option ]
          end
        end
        Choice.new(
          component:,
          field:,
          value:,
          item:,
          index:,
          type:,
        )
      end
    end
  end
end
