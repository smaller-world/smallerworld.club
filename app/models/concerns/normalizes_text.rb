# typed: true
# frozen_string_literal: true

module NormalizesText
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ActiveRecord::Base }

  class_methods do
    extend T::Sig
    extend T::Helpers

    requires_ancestor { T.class_of(ActiveRecord::Base) }

    # == Methods ==

    sig { params(attributes: T.any(Symbol, String)).void }
    def nilify_blanks(*attributes)
      normalizes(*T.unsafe(attributes), with: ->(value) { value.presence })
    end

    sig { params(attributes: T.any(Symbol, String)).void }
    def strips_text(*attributes)
      normalizes(*T.unsafe(attributes), with: ->(value) {
        s = T.cast(value, String)
        s.strip
      })
    end
  end
end
