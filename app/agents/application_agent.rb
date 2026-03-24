# typed: true
# frozen_string_literal: true

class ApplicationAgent < ActiveAgent::Base
  extend T::Sig

  include Pagy::Method
  include TaggedLogging
  include UrlHelpers

  # == Constants ==

  TOOL_CALL_INFO_RESPONSE_FORMAT = {
    type: "json_schema",
    json_schema: {
      name: "tool_call_info",
      schema: {
        type: "object",
        properties: {
          tools_used: {
            type: "array",
            description: "a list of tools you used during the session",
            items: {
              type: "string",
            },
          },
        },
        required: [ "tools_used" ],
        additionalProperties: false,
      },
      strict: true,
    },
  }

  # == Configuration ==

  # generate_with :open_router, instructions: true
  # helper AgentHelper

  # == URL Generation ==

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def default_url_options
    ActionMailer::Base.default_url_options
  end
end
