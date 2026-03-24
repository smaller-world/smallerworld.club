# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: ai_chat_messages
#
#  id                    :uuid             not null, primary key
#  cache_creation_tokens :integer
#  cached_tokens         :integer
#  content               :text
#  content_raw           :json
#  input_tokens          :integer
#  output_tokens         :integer
#  role                  :string           not null
#  thinking_signature    :text
#  thinking_text         :text
#  thinking_tokens       :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  chat_id               :uuid             not null
#  model_id              :uuid
#  tool_call_id          :uuid
#
# Indexes
#
#  index_ai_chat_messages_on_chat_id       (chat_id)
#  index_ai_chat_messages_on_model_id      (model_id)
#  index_ai_chat_messages_on_role          (role)
#  index_ai_chat_messages_on_tool_call_id  (tool_call_id)
#
# Foreign Keys
#
#  fk_rails_...  (chat_id => ai_chats.id)
#  fk_rails_...  (model_id => ai_models.id)
#  fk_rails_...  (tool_call_id => ai_tool_calls.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class AIChatMessage < ApplicationRecord
  # == Configuration ==

  acts_as_message chat_class: "AIChat",
                  chat_foreign_key: :chat_id,
                  tool_call_class: "AIToolCall",
                  tool_calls_foreign_key: :tool_call_id,
                  model_class: "AIModel",
                  model_foreign_key: :model_id

  # == Associations ==

  has_many_attached :attachments
end
