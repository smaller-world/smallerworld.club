# typed: strict
# frozen_string_literal: true

class SmallerWorld::Application
  sig { returns(Stytch::Client) }
  def stytch_client
    @stytch_client ||= T.let(
      begin
        credentials = Rails.application.credentials.stytch!
        Stytch::Client.new(
          project_id: credentials.project_id!,
          secret: credentials.secret!,
          env:   Rails.env.production? ? :live : :test
        )
      end,
      T.nilable(Stytch::Client),
    )
  end
end
