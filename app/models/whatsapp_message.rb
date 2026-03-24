# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: whatsapp_messages
#
#  id                     :uuid             not null, primary key
#  body                   :text             not null
#  mentioned_jids         :string           default([]), not null, is an Array
#  quoted_message_body    :text
#  quoted_participant_jid :string
#  reply_sent_at          :timestamptz
#  timestamp              :timestamptz      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  group_id               :uuid             not null
#  quoted_message_id      :uuid
#  sender_id              :uuid             not null
#  whatsapp_id            :string           not null
#
# Indexes
#
#  index_whatsapp_messages_on_body_tsearch       (to_tsvector('simple'::regconfig, COALESCE(body, ''::text))) USING gin
#  index_whatsapp_messages_on_group_id           (group_id)
#  index_whatsapp_messages_on_quoted_message_id  (quoted_message_id)
#  index_whatsapp_messages_on_reply_sent_at      (reply_sent_at)
#  index_whatsapp_messages_on_sender_id          (sender_id)
#  index_whatsapp_messages_on_timestamp          (timestamp)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => whatsapp_groups.id)
#  fk_rails_...  (quoted_message_id => whatsapp_messages.id)
#  fk_rails_...  (sender_id => whatsapp_users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WhatsappMessage < ApplicationRecord
  include WhatsappMessaging
  include Turbo::Broadcastable
  include PgSearch::Model

  # == Associations ==

  belongs_to :group, class_name: "WhatsappGroup", inverse_of: :messages
  belongs_to :sender, class_name: "WhatsappUser", autosave: true

  belongs_to :quoted_message, class_name: "WhatsappMessage", optional: true

  has_many :mentions,
           class_name: "WhatsappMessageMention",
           dependent: :destroy,
           inverse_of: :message,
           foreign_key: :message_id
  has_many :mentioned_users, through: :mentions

  sig { returns(WhatsappGroup) }
  def group!
    group or raise ActiveRecord::RecordNotFound, "Missing associated group"
  end

  sig { returns(WhatsappUser) }
  def sender!
    sender or raise ActiveRecord::RecordNotFound, "Missing sender"
  end

  # == Hooks ==

  after_create_commit :send_reply_later, if: :requires_reply?
  after_create_commit :append_to_group_message_history

  # == Handling ==

  scope :requiring_reply, -> {
    sender_id = WhatsappUser.where(lid: application_user_lid).select(:id)
    where(reply_sent_at: nil).where.not(sender_id:)
      .and(
        where(quoted_participant_jid: application_user_lid).or(
          where("? = ANY(mentioned_jids)", application_user_lid),
        ),
      )
  }

  pg_search_scope :search, against: [ :body ], using: {
    tsearch: {},
  }

  sig { returns(T::Boolean) }
  def reply_sent? = reply_sent_at?

  sig { returns(T::Boolean) }
  def requires_reply?
    !reply_sent? && !from_application_user? && (
      quoted_participant_jid == application_user_lid ||
        mentioned_jids.include?(application_user_lid)
    )
  end

  # == Replying ==

  sig { returns(ActiveAgent::Generation) }
  def reply_prompt
    WhatsappGroupAgent.with(group: group!, message: self).reply
  end

  sig { void }
  def send_reply
    reply_prompt.generate_now
    update!(reply_sent_at: Time.current)
  rescue => error
    tag_logger do
      logger.warn(
        "Failed to reply to message (#{whatsapp_id}); sending failure message",
      )
    end
    send_reply_failure_message(error)
    raise
  end

  sig do
    params(options: T.untyped)
      .returns(T.any(SendWhatsappGroupReplyJob, FalseClass))
  end
  def send_reply_later(**options)
    SendWhatsappGroupReplyJob.set(**options).perform_later(self)
  end

  # == Methods

  sig { returns(T::Boolean) }
  def from_application_user?
    sender&.lid == application_user_lid
  end

  sig do
    params(limit: Integer).returns(WhatsappMessage::PrivateAssociationRelation)
  end
  def previous_messages(limit:)
    group!.messages
      .where(timestamp: ...timestamp)
      .order(timestamp: :desc)
      .limit(limit)
      .distinct
  end

  sig do
    params(limit: Integer).returns(WhatsappMessage::PrivateAssociationRelation)
  end
  def next_messages(limit:)
    group!.messages
      .where(timestamp: timestamp...)
      .order(timestamp: :asc)
      .limit(limit)
      .distinct
  end

  # == Helpers ==

  sig { params(payload: T::Hash[String, T.untyped]).returns(WhatsappMessage) }
  def self.from_webhook_payload(payload)
    event = payload.fetch("event")
    case event
    when "messages.upsert"
      data = payload.dig!("data", "messages")
      key = data.fetch("key")

      sender = WhatsappUser.from_webhook_payload(payload)
      group = WhatsappGroup.find_or_create_by!(jid: key.fetch("remoteJid"))
      timestamp_value = data.fetch("messageTimestamp")
      message_data = data.fetch("message")

      WhatsappMessage.find_or_initialize_by(
        whatsapp_id: key.fetch("id"),
      ) do |message|
        message.group = group
        message.sender = sender
        message.timestamp = parse_webhook_timestamp(timestamp_value)
        message.attributes = parse_webhook_message(message_data)
      end

    when "message.sent"
      data = payload.fetch("data")
      key = data.fetch("key")

      sender = WhatsappUser.find_or_initialize_by(lid: application_user_lid)
      group = WhatsappGroup.find_or_initialize_by(jid: key.fetch("remoteJid"))
      timestamp_value = payload.fetch("timestamp")
      message_data = data.fetch("message")

      WhatsappMessage.find_or_initialize_by(
        whatsapp_id: key.fetch("id"),
      ) do |message|
        message.group = group
        message.sender = sender
        message.timestamp = parse_webhook_timestamp(timestamp_value)
        message.attributes = parse_webhook_message(message_data)
      end

    else
      raise "Unsupported event: #{event}"
    end
  end

  private

  # == Helpers ==

  sig do
    params(value: T.any(Integer, T::Hash[String, T.untyped]))
      .returns(ActiveSupport::TimeWithZone)
  end
  private_class_method def self.parse_webhook_timestamp(value)
    timestamp = value.is_a?(Hash) ? value.fetch("low") : value
    Time.zone.at(timestamp)
  end

  sig do
    params(data: T::Hash[String, T.untyped]).returns(T::Hash[Symbol, T.untyped])
  end
  private_class_method def self.parse_webhook_message(data)
    body = parse_message_text(data) or raise "Missing message body"
    if (context_info = data.dig("extendedTextMessage", "contextInfo"))
      mentioned_jids = context_info.fetch("mentionedJid") { [] }
      if (message_data = context_info["quotedMessage"])
        quoted_message_body = parse_message_text(message_data) or
          raise "Missing quoted message body"
        quoted_participant_jid = context_info.fetch("participant")
        stanza_id = context_info.fetch("stanzaId")
        quoted_message = WhatsappMessage.find_by(whatsapp_id: stanza_id)
      end
    end
    {
      body:,
      quoted_message_body:,
      quoted_participant_jid:,
      quoted_message:,
      mentioned_jids: mentioned_jids || [],
      mentioned_users:
        mentioned_jids ? WhatsappUser.from_mentioned_jids(mentioned_jids) : [],
    }
  end

  sig { params(data: T::Hash[String, T.untyped]).returns(T.nilable(String)) }
  private_class_method def self.parse_message_text(data)
    data["conversation"] || data.dig("extendedTextMessage", "text")
  end

  sig { params(error: Exception).void }
  def send_reply_failure_message(error)
    sender = sender!
    text = <<~EOF.squish
      **SYSTEM FAILURE!**
      CRITICAL MALFUNCTION while responding to your message:
      #{error.message}

      the developer has been notified.
    EOF
    if (embedded_mention = sender.phone_mention_token)
      text = "#{embedded_mention} #{text}"
    end
    group!.send_message(text: text, mentioned_jids: [ sender.lid ])
  end

  # == Callbacks ==

  sig { void }
  def append_to_group_message_history
    broadcast_append_to(
      group,
      :message_history,
      target: "messages",
      renderable: Components::Chat::Messages::Item.new(message: self),
    )
  end
end
