# typed: strict
# frozen_string_literal: true

# Include this module to make `mix` from Phlex::Helpers automatically handle nil values.
module CompactMixing
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::Helpers }

  # == Methods ==

  sig { params(args: T.untyped).returns(T::Hash[Symbol, T.untyped]) }
  def mix(*args)
    super(*T.unsafe(args.compact))
  end
end
