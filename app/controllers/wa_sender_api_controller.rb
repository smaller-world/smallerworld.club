# typed: true
# frozen_string_literal: true

class WaSenderApiController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_forgery_protection

  # == Filters ==

  before_action :verify_webhook_signature!
  after_action :forward_webhook_message_to_dev_server if Rails.env.production?

  # == Actions ==

  sig { void }
  def webhook
    payload = JSON.parse(request.raw_post)
    event = payload.fetch("event")

    # Log webhook message
    webhook_message = WebhookMessage.from_webhook_payload(payload)
    webhook_message.save!

    # Handle event
    case event
    when "messages.upsert", "message.sent"
      begin
        message = WhatsappMessage.from_webhook_payload(payload)
        message.save!
      rescue => error
        tag_logger(event) do
          logger.warn(
            "Couldn't create WhatsappMessage: #{error.message}",
          )
        end
      end
    when "groups.upsert"
      data = payload.fetch("data")
      if (group = WhatsappGroup.find_or_create_by!(jid: data.fetch("jid")))
        group.import_metadata_later unless group.previously_new_record?
      end
    when "group-participants.update"
      data = payload.fetch("data")
      if (jid = data["jid"])
        if (group = WhatsappGroup.find_by(jid:))
          group.import_memberships_later
        else
          tag_logger(event) do
            logger.warn("Couldn't find WhatsappGroup: #{jid}")
          end
        end
      end
    end
    head(:ok)
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def webhook_signature!
    request.headers["X-Webhook-Signature"] or raise "Missing webhook signature"
  end

  sig { void }
  def verify_webhook_signature!
    signature = request.headers["X-Webhook-Signature"]
    secret = webhook_secret

    unless ActiveSupport::SecurityUtils
        .secure_compare(signature.to_s, secret.to_s)
      head(:unauthorized)
    end
  end

  sig { returns(String) }
  def webhook_secret
    Rails.application.credentials.dig(:wa_sender_api, :webhook_secret) or
      raise "Missing WASenderAPI webhook secret"
  end

  # == Callbacks ==

  sig { void }
  def forward_webhook_message_to_dev_server
    ForwardWebhookMessageToDevServerJob.perform_later(
      body: request.raw_post,
      webhook_signature: webhook_signature!,
    )
  end
end
