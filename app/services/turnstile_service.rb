# typed: true
# frozen_string_literal: true

class TurnstileService < ApplicationService
  # == Configuration ==

  sig { override.returns(T::Boolean) }
  def self.enabled?
    Turnstile.settings.present?
  end

  # == Initialization ==

  sig { void }
  def initialize
    super
    @conn = Faraday.new("https://challenges.cloudflare.com") do |f|
      f.request(:url_encoded)
      f.response(:json)
    end
  end

  sig { returns(Faraday::Connection) }
  attr_reader :conn

  # == Methods ==

  sig do
    params(
      token: String,
      remoteip: T.nilable(String),
      idempotency_key: T.nilable(String),
    ).returns(T::Boolean)
  end
  def self.verify(token:, remoteip: nil, idempotency_key: nil)
    body = {
      secret: settings!.secret_key,
      response: token,
    }
    body[:remoteip] = remoteip if remoteip
    body[:idempotency_key] = idempotency_key if idempotency_key

    response = instance.conn.post("/turnstile/v0/siteverify", body)
    response.body["success"] == true
  end

  sig { returns(Turnstile::Settings) }
  def self.settings!
    Turnstile.settings or raise "Missing Turnstile settings"
  end
end
