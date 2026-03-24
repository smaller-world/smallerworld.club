# typed: true
# frozen_string_literal: true

require "test_helper"

class WhatsappGroupAgentTest < ActiveSupport::TestCase
  extend T::Sig

  # == Action: `introduce_yourself' ==

  test "introduce_yourself calls required tools" do
    group = whatsapp_groups(:hangout)
    response = retry_on(OpenAI::Errors::RateLimitError) do
      WhatsappGroupAgent.with(group:)
        .introduce_yourself
        .generate_now
    end
    tool_calls = tool_calls_from_response(response)

    assert_includes tool_calls,
                    :send_message,
                    "Expected `send_message' tool usage"
    # assert_includes tool_calls,
    #                 :send_message_history_link,
    #                 "Expected `send_message_history_link' tool usage"
    "once"
  end

  # == Action: `reply' ==

  test "reply calls required tools" do
    group = whatsapp_groups(:hangout)
    message = whatsapp_messages(:hello_message)
    response = retry_on(OpenAI::Errors::RateLimitError) do
      WhatsappGroupAgent.with(group:, message:)
        .reply
        .generate_now
    end
    tool_calls = tool_calls_from_response(response)

    assert_includes tool_calls, :send_reply, "Expected `send_reply' tool usage"
    assert_not_includes tool_calls,
                        :send_message_history_link,
                        "Expected no `send_message_history_link' tool usage"
  end

  test "reply searches for messages" do # rubocop:disable Minitest/MultipleAssertions
    group = whatsapp_groups(:hangout)
    message = whatsapp_messages(:who_talked_about_fries_message)

    sent_replies = []
    capture_reply = lambda do |text:, **|
      sent_replies << text
    end
    response = group.stub(:send_message, capture_reply) do
      retry_on(OpenAI::Errors::RateLimitError) do
        WhatsappGroupAgent.with(group:, message:)
          .reply
          .generate_now
      end
    end
    tool_calls = tool_calls_from_response(response)

    assert_includes tool_calls,
                    :search_messages,
                    "Expected `search_messages' tool usage"
    assert_includes tool_calls,
                    :send_reply,
                    "Expected `send_reply' tool usage"
    assert_not_empty sent_replies, "Expected at least one reply to be sent"
    assert_match(
      /BOB/,
      sent_replies.last,
      "Expected reply to contain 'BOB'",
    )
  end

  test "reply with message history link when requested" do
    group = whatsapp_groups(:hangout)
    message = whatsapp_messages(:message_history_request_message)
    response = retry_on(OpenAI::Errors::RateLimitError) do
      WhatsappGroupAgent.with(group:, message:)
        .reply
        .generate_now
    end
    tool_calls = tool_calls_from_response(response)

    assert_includes tool_calls,
                    :send_message_history_link,
                    "Expected `send_message_history_link' tool usage"
  end

  private

  # == Helpers ==

  sig do
    params(response: ActiveAgent::Providers::Common::Responses::Prompt)
      .returns(T::Array[Symbol])
  end
  def tool_calls_from_response(response)
    content = response.message.content

    assert_not_empty content,
                     "Expected agent to respond with tool usage details"

    begin
      tools_used = JSON.parse(content).fetch("tools_used")

      assert_kind_of Array,
                     tools_used,
                     "Expected 'tools_used' to be an array"
      assert_not_empty tools_used,
                       "Expected 'tools_used' to be non-empty"
      tools_used.map(&:to_sym)
    rescue JSON::ParserError, KeyError
      flunk(
        "Expected tool usage details to be a JSON object with `tools_used` key",
      )
    end
  end
end
