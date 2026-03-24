# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: webhook_messages
#
#  id         :uuid             not null, primary key
#  data       :jsonb            not null
#  event      :string           not null
#  timestamp  :timestamptz      not null
#  created_at :timestamptz      not null
#
# Indexes
#
#  index_webhook_messages_on_timestamp  (timestamp)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WebhookMessage < ApplicationRecord
  # == Validations ==

  validates :timestamp, presence: true
  validates :data, presence: true

  # == Methods ==

  sig { returns(T.nilable(WhatsappGroup)) }
  def associated_whatsapp_group
    if (jid = data.dig("messages", "remoteJid"))
      WhatsappGroup.find_by(jid:)
    end
  end

  # == Helpers ==

  sig { params(payload: T::Hash[String, T.untyped]).returns(WebhookMessage) }
  def self.from_webhook_payload(payload)
    event = payload.fetch("event")
    timestamp = Time.zone.at(payload.fetch("timestamp") / 1000.0)
    data = payload.fetch("data")
    WebhookMessage.new(event:, timestamp:, data:)
  end
end
