# typed: true
# frozen_string_literal: true

require "openai"

class OpenRouter
  extend T::Sig

  # == Typechecking ==

  Message = T.type_alias { { role: String, content: String } }

  # == Configuration ==

  sig { params(api_key: String).void }
  def initialize(api_key:)
    @client = T.let(
      OpenAI::Client.new(
        base_url: "https://openrouter.ai/api/v1",
        api_key:,
      ),
      OpenAI::Client,
    )
  end

  # == Methods ==

  sig { params(messages: T::Array[Message]).returns(String) }
  def complete_chat(messages = [])
    response = @client.chat.completions.create(
      model: "openrouter/pony-alpha",
      messages:,
    )
    response.choices.first&.message&.content or raise "Missing response content"
  end
end
