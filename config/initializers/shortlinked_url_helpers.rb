# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig do
    params(fallback_url_options: T::Hash[Symbol, T.untyped])
      .returns(ShortlinkedUrlHelpers)
  end
  def shortlinked_url_helpers(fallback_url_options = {})
    @shortlinked_url_helpers ||= T.let(
      if Rails.env.production?
        ShortlinkedUrlHelpers.new(protocol: "https", host: "smlr.world")
      else
        ShortlinkedUrlHelpers.new(**fallback_url_options)
      end,
      T.nilable(ShortlinkedUrlHelpers),
    )
  end
end
