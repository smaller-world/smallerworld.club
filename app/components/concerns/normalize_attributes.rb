# typed: strict
# frozen_string_literal: true

module NormalizeAttributes
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::HTML }

  # == Methods ==

  sig do
    params(attributes: T::Hash[Symbol, T.untyped])
      .returns(T::Hash[Symbol, T.untyped])
  end
  private def normalize_attributes(attributes)
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
end
