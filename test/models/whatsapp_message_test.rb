# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: whatsapp_messages
#
#  id                     :uuid             not null, primary key
#  body                   :text             not null
#  mentioned_jids         :string           default([]), not null, is an Array
#  quoted_message_body    :text
#  quoted_participant_jid :string
#  reply_sent_at          :timestamptz
#  timestamp              :timestamptz      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  group_id               :uuid             not null
#  quoted_message_id      :uuid
#  sender_id              :uuid             not null
#  whatsapp_id            :string           not null
#
# Indexes
#
#  index_whatsapp_messages_on_body_tsearch       (to_tsvector('simple'::regconfig, COALESCE(body, ''::text))) USING gin
#  index_whatsapp_messages_on_group_id           (group_id)
#  index_whatsapp_messages_on_quoted_message_id  (quoted_message_id)
#  index_whatsapp_messages_on_reply_sent_at      (reply_sent_at)
#  index_whatsapp_messages_on_sender_id          (sender_id)
#  index_whatsapp_messages_on_timestamp          (timestamp)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => whatsapp_groups.id)
#  fk_rails_...  (quoted_message_id => whatsapp_messages.id)
#  fk_rails_...  (sender_id => whatsapp_users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
require "test_helper"

class WhatsappMessageTest < ActiveSupport::TestCase
  extend T::Sig

  # == Tests ==

  test "search scope uses the body tsearch index" do # rubocop:disable Minitest/MultipleAssertions
    indexes = ActiveRecord::Base.connection.indexes(:whatsapp_messages)

    assert_includes indexes.map(&:name),
                    "index_whatsapp_messages_on_body_tsearch"

    sql = WhatsappMessage.search("fries").to_sql

    assert_match(/@@/, sql)
    assert_match(/to_tsvector\('simple'/, sql)
    assert_match(/coalesce\(/i, sql)
  end
end
