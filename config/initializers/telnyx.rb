# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { returns(Telnyx::Client) }
  def initialize_telnyx_client
    @telnyx_client = T.let(@telnyx_client, T.nilable(Telnyx::Client))
    @telnyx_client = Telnyx::Client.new(
      api_key: Rails.application.credentials.telnyx!.api_key!,
    )
  end

  sig { returns(Telnyx::Client) }
  def telnyx_client
    @telnyx_client ||= initialize_telnyx_client
  end

  sig { returns(String) }
  def telnyx_phone_number
    Rails.application.credentials.telnyx!.phone_number!
  end

  config.to_prepare do
    Smallerworld.application.initialize_telnyx_client
  end
end
