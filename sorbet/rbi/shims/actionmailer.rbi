# typed: true

class ActionMailer::Base
  sig { returns(T::Hash[Symbol, T.untyped]) }
  def self.default_url_options; end
end
