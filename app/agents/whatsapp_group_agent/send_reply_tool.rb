# typed: true
# frozen_string_literal: true

class WhatsappGroupAgent
  module SendReplyTool
    extend T::Sig
    extend T::Helpers

    requires_ancestor { WhatsappGroupAgent }

    extend ActiveSupport::Concern

    # == Tool ==

    SEND_REPLY_TOOL = {
      name: "send_reply",
      description: "Send a reply to the received message.",
      parameters: {
        type: "object",
        properties: {
          text: {
            type: "string",
          },
        },
        required: [ "text" ],
      },
    }

    # == Execution ==

    sig { params(text: String).returns(String) }
    def send_reply(text:)
      sender = message!.sender!
      if (mention_token = sender.phone_mention_token) &&
          mentioned_jids_in(text).exclude?(sender.lid)
        tag_logger do
          logger.debug(
            "Adding sender mention (#{mention_token}) to reply message: #{text}",
          )
        end
        text = "#{sender.phone_mention_token} #{text}"
      end
      group = group!
      jid = group.jid
      tag_logger do
        logger.info("Sending reply to group #{jid}: #{text}")
      end
      mentioned_jids = mentioned_jids_in(text)
      group.send_message(text:, mentioned_jids:)
      JSON.pretty_generate({ success: true })
    rescue => error
      tag_logger do
        logger.error("Failed to send reply to group #{jid}: #{error}")
      end
      JSON.pretty_generate({ error: error.message })
    end
  end
end
