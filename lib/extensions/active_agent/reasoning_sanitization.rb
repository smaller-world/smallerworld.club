# typed: true
# frozen_string_literal: true

require "active_agent/providers/open_ai/chat/transforms"

module ActiveAgent::Providers::OpenAI::Chat::Transforms
  class << self
    module ReasoningSanitizer
      UNSUPPORTED_ASSISTANT_KEYS = [
        :reasoning,
        :reasoning_details,
        "reasoning",
        "reasoning_details",
      ].freeze

      def simplify_messages(messages)
        super.map do |message|
          role = message[:role] || message["role"]
          next message unless role == "assistant"

          sanitized = message.except(*UNSUPPORTED_ASSISTANT_KEYS)
          tool_calls = sanitized[:tool_calls] || sanitized["tool_calls"]

          if tool_calls.present? && !sanitized.key?(:content) && !sanitized.key?("content")
            sanitized["content"] = ""
          end

          sanitized
        end
      end
    end

    prepend ReasoningSanitizer
  end
end
