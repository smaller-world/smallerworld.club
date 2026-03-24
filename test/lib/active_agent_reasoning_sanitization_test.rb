# rubocop:disable Minitest/MultipleAssertions, Lint/MissingCopEnableDirective
# typed: ignore # rubocop:disable Sorbet/TrueSigil
# frozen_string_literal: true

require "test_helper"

class ActiveAgentReasoningSanitizationTest < ActiveSupport::TestCase
  def test_simplify_messages_strips_unsupported_reasoning_fields_from_assistant_messages
    messages = [
      {
        role: "assistant",
        content: "I found a result",
        reasoning: "private chain of thought",
        reasoning_details: [ { type: "reasoning.text", text: "hidden" } ],
        tool_calls: [
          {
            id: "call_123",
            type: "function",
            function: { name: "search_messages", arguments: "{\"query\":\"fries\"}" },
          },
        ],
      },
    ]

    simplified = ActiveAgent::Providers::OpenAI::Chat::Transforms.simplify_messages(messages)

    assert_equal 1, simplified.size
    assert_equal "assistant", simplified.first[:role]
    assert_equal "I found a result", simplified.first[:content]
    assert_equal messages.first[:tool_calls], simplified.first[:tool_calls]
    assert_not_includes simplified.first.keys, :reasoning
    assert_not_includes simplified.first.keys, :reasoning_details
  end

  def test_simplify_messages_strips_unsupported_reasoning_fields_from_string_keyed_assistant_messages
    messages = [
      {
        "role" => "assistant",
        "content" => "I found a result",
        "reasoning" => "private chain of thought",
        "reasoning_details" => [ { "type" => "reasoning.text", "text" => "hidden" } ],
        "tool_calls" => [
          {
            "id" => "call_123",
            "type" => "function",
            "function" => { "name" => "search_messages", "arguments" => "{\"query\":\"fries\"}" },
          },
        ],
      },
    ]

    simplified = ActiveAgent::Providers::OpenAI::Chat::Transforms.simplify_messages(messages)

    assert_equal 1, simplified.size
    assert_equal "assistant", simplified.first["role"]
    assert_equal "I found a result", simplified.first["content"]
    assert_equal messages.first["tool_calls"], simplified.first["tool_calls"]
    assert_not_includes simplified.first.keys, "reasoning"
    assert_not_includes simplified.first.keys, "reasoning_details"
  end

  def test_simplify_messages_adds_empty_content_for_assistant_tool_call_messages
    messages = [
      {
        "role" => "assistant",
        "tool_calls" => [
          {
            "id" => "call_123",
            "type" => "function",
            "function" => { "name" => "send_reply", "arguments" => "{\"text\":\"hi\"}" },
          },
        ],
      },
    ]

    simplified = ActiveAgent::Providers::OpenAI::Chat::Transforms.simplify_messages(messages)

    assert_equal "", simplified.first["content"]
    assert_equal messages.first["tool_calls"], simplified.first["tool_calls"]
  end
end
