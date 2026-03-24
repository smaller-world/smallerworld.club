# typed: true
# frozen_string_literal: true

class WhatsappGroupAgent
  module ConfigureMessageHistoryTool
    extend T::Sig
    extend T::Helpers

    requires_ancestor { WhatsappGroupAgent }

    extend ActiveSupport::Concern

    # == Tool ==

    CONFIGURE_MESSAGE_HISTORY_TOOL = {
      name: "configure_message_history",
      description: "Update the message history settings for this group.",
      parameters: {
        type: "object",
        properties: {
          enabled: {
            type: "boolean",
            description: "Whether to enable message history webpage.",
          },
          window_days: {
            type: "integer",
            description:
              "Number of days of history to display. Set to null for " \
              "indefinite history.",
          },
        },
        required: [ "enabled", "window_days" ],
      },
    }

    # == Execution ==

    sig { params(enabled: T::Boolean, window_days: T.nilable(Integer)).returns(String) }
    def configure_message_history(enabled:, window_days:)
      group = group!
      begin
        updates = {
          message_history_enabled_at: enabled ? Time.current : nil,
          message_history_window_days: window_days,
        }
        group.update!(updates)

        tag_logger do
          logger.info(
            "Configured message history for group #{group.jid}: #{updates}",
          )
        end

        JSON.pretty_generate({ success: true })
      rescue => error
        tag_logger do
          logger.error(
            "Failed to configure message history for group #{group.jid}: " \
              "#{error}",
          )
        end
        JSON.pretty_generate({ error: error.message })
      end
    end
  end
end
