# typed: true
# frozen_string_literal: true

class WhatsappGroupAgent
  module SendMessageTool
    extend T::Sig
    extend T::Helpers

    requires_ancestor { WhatsappGroupAgent }

    extend ActiveSupport::Concern

    # == Tool ==

    SEND_MESSAGE_TOOL = {
      name: "send_message",
      description: "Send a message to the group.",
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

    sig { params(text: String).returns(String) }
    def send_message(text:)
      group = group!
      jid = group.jid
      tag_logger do
        logger.info("Sending message to group #{jid}: #{text}")
      end
      mentioned_jids = mentioned_jids_in(text)
      group.send_message(text:, mentioned_jids:)
      JSON.pretty_generate({ success: true })
    rescue => error
      tag_logger do
        logger.error("Failed to send message to group #{jid}: #{error}")
      end
      JSON.pretty_generate({ error: error.message })
    end

    private

    # == Helpers ==

    sig { params(text: String).returns(T::Array[String]) }
    def mentioned_jids_in(text)
      mentions = text.scan(/@(\d+)/).flatten
      mentioned_numbers = mentions.map do |mention|
        phone = Phonelib.parse(mention.delete_prefix("@"))
        phone.to_s
      end
      WhatsappUser.where(phone_number: mentioned_numbers).distinct.pluck(:lid)
    end
  end
end
