# typed: strict
# frozen_string_literal: true

module Turnstile
  class Client
    extend T::Sig

    sig { params(secret_key: String).void }
    def initialize(secret_key: Turnstile.secret_key)
      @secret_key = secret_key
      @session = T.let(
        HTTP.base_uri("https://challenges.cloudflare.com/turnstile/v0"),
        HTTP::Session,
      )
    end

    sig { params(response: String, remoteip: String).returns(TrueClass) }
    def verify(response:, remoteip:)
      response = @session.post(
        "siteverify",
        form: {
          secret: @secret_key,
          response:,
          remoteip:,
        },
      )
      data = response.parse
      if data.fetch("success")
        true
      else
        error_codes = data.fetch("error-codes")
        raise Error, "Validation failed: #{error_codes}"
      end
    end
  end
end
