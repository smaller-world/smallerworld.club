# typed: true
# frozen_string_literal: true

require "action_push_native"

class ActionPushNative::Service::Apns
  class TokenProvider
    module OpenSSL3Compatibility
      extend T::Helpers

      requires_ancestor { TokenProvider }

      private

      def generate
        payload = { iss: config.fetch(:team_id), iat: Time.now.utc.to_i }
        header = { kid: config.fetch(:key_id) }
        private_key = OpenSSL::PKey.read(config.fetch(:encryption_key))
        JWT.encode(payload, private_key, "ES256", header)
      end
    end

    prepend OpenSSL3Compatibility
  end
end
