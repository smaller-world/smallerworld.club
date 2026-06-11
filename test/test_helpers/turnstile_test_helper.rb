# typed: strict
# frozen_string_literal: true

# Swaps the application's Turnstile client for one using a Cloudflare
# server-side test secret key. Block-scoped via Minitest's `stub`.
# NOTE: the test keys still make a real (deterministic) call to Cloudflare.
module TurnstileTestHelper
  extend T::Sig

  sig do
    type_parameters(:U)
      .params(behavior: Symbol, block: T.proc.returns(T.type_parameter(:U)))
      .returns(T.type_parameter(:U))
  end
  def with_turnstile(behavior:, &block)
    key = Rails.configuration.x.turnstile_test_secret_keys.fetch(:"#{behavior}_key")
    client = Turnstile::Client.new(secret_key: key)
    Smallerworld.application.stub(:turnstile_client, client, &block)
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include TurnstileTestHelper
end
