# typed: strict
# frozen_string_literal: true

module AttributeHelpers
  extend T::Sig
  extend T::Helpers
  include Phlex::Rails::Helpers::TokenList

  requires_ancestor { Phlex::HTML }

  # == Methods ==

  sig do
    params(attributes: T::Hash[Symbol, T.untyped])
      .returns(T::Hash[Symbol, T.untyped])
  end
  def normalize_attributes(attributes)
    attributes.transform_values do |value|
      case value
      when Hash
        normalize_attributes(value)
      when Array
        value.join(" ")
      else
        value
      end
    end
  end

  sig { params(args: T.untyped).returns(T::Hash[Symbol, T.untyped]) }
  def compact_mix(*args)
    mix(*T.unsafe(args.compact))
  end

  sig { params(args: T.untyped).returns(T::Hash[Symbol, T.untyped]) }
  def normalize_mix(*args)
    normalize_attributes(mix(*T.unsafe(args.compact)))
  end
end
