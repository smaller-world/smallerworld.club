# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig do
    params(fallback_url_options: T::Hash[Symbol, T.untyped])
      .returns(UrlHelpers)
  end
  def shortlinked_url_helpers(
    fallback_url_options = Rails.configuration.action_mailer.default_url_options
  )
    if Rails.env.production?
      UrlHelpers.new(protocol: "https", host: "smlr.world")
    else
      UrlHelpers.new(**fallback_url_options)
    end
  end
end
