# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: whatsapp_message_mentions
#
#  id                :uuid             not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  mentioned_user_id :uuid             not null
#  message_id        :uuid             not null
#
# Indexes
#
#  index_whatsapp_message_mentions_on_mentioned_user_id  (mentioned_user_id)
#  index_whatsapp_message_mentions_on_message_id         (message_id)
#
# Foreign Keys
#
#  fk_rails_...  (mentioned_user_id => whatsapp_users.id)
#  fk_rails_...  (message_id => whatsapp_messages.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WhatsappMessageMention < ApplicationRecord
  # == Associations ==

  belongs_to :message, class_name: "WhatsappMessage"
  belongs_to :mentioned_user, class_name: "WhatsappUser"
end
