# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "rails"

module Turnstile
  extend T::Sig

  # == Errors ==
  class Error < StandardError
  end
end
