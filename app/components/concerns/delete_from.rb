# typed: strict
# frozen_string_literal: true

module DeleteFrom
  extend T::Sig

  # == Helpers ==

  sig do
    params(hash: T::Hash[Symbol, T.untyped], keys: Symbol)
      .returns(T::Hash[Symbol, T.untyped])
  end
  private def delete_from(hash, *keys)
    deleted_values = T.let({}, T::Hash[Symbol, T.untyped])
    keys.each do |key|
      if hash.key?(key)
        deleted_values[key] = hash.delete(key)
      end
    end
    deleted_values
  end
end
