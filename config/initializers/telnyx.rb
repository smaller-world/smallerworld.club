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

  sig { returns(String) }
  def telnyx_phone_number
    Rails.application.credentials.telnyx!.phone_number!
  end
end
