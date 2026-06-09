# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "rails"

class UrlHelpers
  extend T::Sig

  T.unsafe(self).include(Rails.application.routes.url_helpers)

  sig { params(url_options: T.untyped).void }
  def initialize(**url_options)
    @url_options = url_options
  end

  private

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def default_url_options
    @url_options
  end
end
