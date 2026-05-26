# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { returns(Turnstile::Client) }
  def turnstile_client
    @turnstile_client ||= T.let(Turnstile::Client.new, T.nilable(Turnstile::Client))
  end

  sig { void }
  def invalidate_turnstile_client
    @turnstile_client = nil
  end
end

# Invalidate memoized value after hot-reload
Rails.application.reloader.to_complete do
  Smallerworld.application.invalidate_turnstile_client
end
