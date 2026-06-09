# typed: strict
# frozen_string_literal: true

class Phlex::SGML
  class << self
    sig do
      params(a: T.untyped, k: T.untyped, block: T.untyped)
        .returns(T.attached_class)
    end
    def new(*a, **k, &block); end
  end
end
