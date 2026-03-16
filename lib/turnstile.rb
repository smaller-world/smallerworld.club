# typed: true
# frozen_string_literal: true

require "sorbet-runtime"

module Turnstile
  extend T::Sig

  class Settings < T::Struct
    extend T::Sig

    # == Properties ==

    const :site_key, String
    const :secret_key, String
  end

  # == Methods ==

  sig { returns(T.nilable(Settings)) }
  def self.settings
    return @_settings if defined?(@_settings)

    @_settings = if (credentials = self.credentials)
      Settings.new(
        site_key: credentials.site_key!,
        secret_key: credentials.secret_key!,
      )
    end
  end

  # == Helpers ==

  sig { returns(T.untyped) }
  def self.credentials
    Rails.application.credentials.turnstile
  end
end
