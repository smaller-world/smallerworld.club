# typed: strict

class ActiveRecord::Migration
  sig { params(name: T.untyped, _arg1: T.untyped).void }
  def enable_extension(name, **_arg1); end
end

module ActiveRecord::TokenFor
  sig { params(purpose: Symbol).returns(String) }
  def generate_token_for(purpose); end

  module ClassMethods
    has_attached_class!(:out)

    sig do
      params(
        purpose: Symbol,
        expires_in: T.nilable(T.any(Integer, ActiveSupport::Duration)),
        block: T.nilable(T.proc.bind(T.attached_class).returns(T.untyped)),
      ).void
    end
    def generates_token_for(purpose, expires_in: T.unsafe(nil), &block); end
  end
end
