# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { returns(Telnyx::Client) }
  def telnyx_client
    @telnyx_client ||= T.let(
      Telnyx::Client.new(
        api_key: Rails.application.credentials.telnyx!.api_key!,
      ),
      T.nilable(Telnyx::Client),
    )
  end

  sig { void }
  def invalidate_telnyx_client
    @telnyx_client = nil
  end

  sig { returns(String) }
  def telnyx_phone_number
    Rails.application.credentials.telnyx!.phone_number!
  end
end

# Invalidate memoized value after hot-reload
Rails.application.reloader.to_complete do
  Smallerworld.application.invalidate_telnyx_client
end
