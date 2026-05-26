# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { returns(Turnstile::Client) }
  def initialize_turnstile_client
    @turnstile_client = T.let(@turnstile_client, T.nilable(Turnstile::Client))
    @turnstile_client = Turnstile::Client.new
  end

  sig { returns(Turnstile::Client) }
  def turnstile_client
    @turnstile_client ||= initialize_turnstile_client
  end

  config.to_prepare do
    Smallerworld.application.initialize_turnstile_client
  end
end
