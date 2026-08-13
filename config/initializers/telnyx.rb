# typed: strict
# frozen_string_literal: true

class SmallerWorld::Application
  sig { returns(Telnyx::Client) }
  def telnyx_client
    @telnyx_client ||= T.let(
      Telnyx::Client.new(
        api_key: credentials.telnyx!.api_key!,
      ),
      T.nilable(Telnyx::Client),
    )
  end

  sig { returns(String) }
  def telnyx_phone_number
    @telnyx_phone_number ||= T.let(
      begin
        number = credentials.telnyx!.phone_number!
        Phonelib::Phone.new(number).to_s
      end,
      T.nilable(String),
    )
  end
end
