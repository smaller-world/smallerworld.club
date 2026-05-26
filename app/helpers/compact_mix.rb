# typed: strict
# frozen_string_literal: true

module CompactMix
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Phlex::Helpers }

  # == Helper ==

  sig { params(args: T.untyped).returns(T::Hash[Symbol, T.untyped]) }
  def compact_mix(*args)
    mix(*T.unsafe(args.compact))
  end
end
