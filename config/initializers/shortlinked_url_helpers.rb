# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { params(fallback_url_options: T::Hash[Symbol, T.untyped]).returns(UrlHelpers) }
  def shortlinked_url_helpers(fallback_url_options = default_url_options)
    if Rails.env.production?
      UrlHelpers.new(protocol: "https", host: "smlr.world")
    else
      UrlHelpers.new(**fallback_url_options)
    end
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def default_url_options
    config.action_mailer.default_url_options
  end
end
