# typed: true
# frozen_string_literal: true

class WhatsappGroupAgent
  module SendMessageHistoryLinkTool
    extend T::Sig
    extend T::Helpers

    requires_ancestor { WhatsappGroupAgent }

    extend ActiveSupport::Concern

    # == Tool ==

    SEND_MESSAGE_HISTORY_LINK_TOOL = {
      name: "send_message_history_link",
      description: "Sends the message history link to the group.",
    }

    # == Execution ==

    sig { returns(String) }
    def send_message_history_link
      group = group!
      jid = group.jid
      begin
        history_url = message_history_whatsapp_group_url(group)
        send_message(text: "*see message history at:* #{history_url}")
        tag_logger do
          logger.info(
            "Sending message history link to group #{jid}: #{history_url}",
          )
        end
        JSON.pretty_generate({ success: true })
      rescue => error
        tag_logger do
          logger.error(
            "Failed to send message history link to group #{jid}: #{error}",
          )
        end
        JSON.pretty_generate({ error: error.message })
      end
    end
  end
end
