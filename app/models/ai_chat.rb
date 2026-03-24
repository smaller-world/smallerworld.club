# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: ai_chats
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  model_id   :uuid
#
# Indexes
#
#  index_ai_chats_on_model_id  (model_id)
#
# Foreign Keys
#
#  fk_rails_...  (model_id => ai_models.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class AIChat < ApplicationRecord
  # == Configuration ==

  acts_as_chat message_class: "AIChatMessage",
               messages_foreign_key: :chat_id,
               model_class: "AIModel",
               model_foreign_key: :model_id
end
