# typed: true
# frozen_string_literal: true

require "openid_connect"

module GoogleSignIn
  class Client < OpenIDConnect::Client
    extend T::Sig

    ISSUER = "https://accounts.google.com"

    class << self
      extend T::Sig

      sig { returns(OpenIDConnect::Discovery::Provider::Config::Response) }
      def discover!
        @discovery_config ||=
          OpenIDConnect::Discovery::Provider::Config.discover!(ISSUER)
      end
    end

    sig do
      params(
        identifier: String,
        secret: String,
        redirect_uri: String,
      ).void
    end
    def initialize(identifier:, secret:, redirect_uri:)
      @provider_config = self.class.discover!
      super(
        identifier:,
        secret:,
        redirect_uri:,
        authorization_endpoint: @provider_config.authorization_endpoint,
        token_endpoint: @provider_config.token_endpoint,
        userinfo_endpoint: @provider_config.userinfo_endpoint,
      )
    end

    sig do
      params(
        scope: T::Array[Symbol],
        state: String,
        nonce: String,
      ).returns(String)
    end
    def authorization_uri(scope:, state:, nonce:)
      super.to_s
    end

    sig { override.returns(OpenIDConnect::AccessToken) }
    def access_token!
      token_response = super
      if (raw_id_token = token_response.id_token).is_a?(String)
        token_response.id_token = OpenIDConnect::ResponseObject::IdToken.decode(
          raw_id_token,
          @provider_config,
        )
      end
      token_response
    end
  end
end
