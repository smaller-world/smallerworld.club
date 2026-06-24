# typed: strict
# frozen_string_literal: true

module NormalizesArrays
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ActiveRecord::Base }

  class_methods do
    extend T::Sig
    extend T::Helpers

    requires_ancestor { T.class_of(ActiveRecord::Base) }

    # == Macros ==

    sig { params(attributes: T.any(Symbol, String)).void }
    def compacts_blanks(*attributes)
      normalizes(*T.unsafe(attributes), with: ->(value) { value&.compact_blank })
    end
  end
end
