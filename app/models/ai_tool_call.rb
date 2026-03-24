# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: ai_tool_calls
#
#  id                :uuid             not null, primary key
#  arguments         :jsonb
#  name              :string           not null
#  thought_signature :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  message_id        :uuid             not null
#  tool_call_id      :string           not null
#
# Indexes
#
#  index_ai_tool_calls_on_message_id    (message_id)
#  index_ai_tool_calls_on_name          (name)
#  index_ai_tool_calls_on_tool_call_id  (tool_call_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (message_id => ai_chat_messages.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class AIToolCall < ApplicationRecord
  # == Configuration ==

  acts_as_tool_call message_class: "AIChatMessage",
                    message_foreign_key: :message_id
end
