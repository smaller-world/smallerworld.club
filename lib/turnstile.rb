# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "rails"

module Turnstile
  extend T::Sig

  # == Errors ==
  class Error < StandardError
  end

  # == Methods ==

  sig { returns(String) }
  def self.site_key
    credentials.site_key!
  end

  sig { returns(String) }
  def self.secret_key
    credentials.secret_key!
  end

  private

  # == Helpers ==

  sig { returns(T.untyped) }
  private_class_method def self.credentials
    Rails.application.credentials.turnstile!
  end
end
