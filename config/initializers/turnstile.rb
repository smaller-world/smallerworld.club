# typed: strict
# frozen_string_literal: true

class SmallerWorld::Application
  sig { returns(String) }
  def turnstile_site_key
    if Rails.env.production?
      credentials.turnstile!.site_key!
    else
      config.x.turnstile_test_site_keys.always_passes_key
    end
  end

  sig { returns(String) }
  def turnstile_secret_key
    if Rails.env.production?
      credentials.turnstile!.secret_key!
    else
      config.x.turnstile_test_secret_keys.always_passes_key
    end
  end

  sig { returns(Turnstile::Client) }
  def turnstile_client
    @turnstile_client ||= T.let(
      Turnstile::Client.new(secret_key: turnstile_secret_key),
      T.nilable(Turnstile::Client),
    )
  end

  sig { void }
  def invalidate_turnstile_client
    @turnstile_client = nil
  end
end

# Invalidate memoized value after hot-reload
Rails.application.reloader.to_complete do
  SmallerWorld.application.invalidate_turnstile_client
end
