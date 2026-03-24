# typed: true
# frozen_string_literal: true

require "test_helper"

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: whatsapp_groups
#
#  id                          :uuid             not null, primary key
#  description                 :text
#  intro_sent_at               :timestamptz
#  jid                         :string           not null
#  memberships_imported_at     :timestamptz
#  message_history_enabled_at  :timestamptz      not null
#  message_history_window_days :integer
#  metadata_imported_at        :timestamptz
#  profile_picture_url         :string
#  subject                     :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_whatsapp_groups_on_intro_sent_at                (intro_sent_at)
#  index_whatsapp_groups_on_jid                          (jid) UNIQUE
#  index_whatsapp_groups_on_memberships_imported_at      (memberships_imported_at)
#  index_whatsapp_groups_on_metadata_imported_at         (metadata_imported_at)
#  index_whatsapp_groups_on_subject_description_tsearch  (((setweight(to_tsvector('simple'::regconfig, (COALESCE(subject, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('simple'::regconfig, COALESCE(description, ''::text)), 'B'::"char")))) USING gin
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WhatsappGroupTest < ActiveSupport::TestCase
  extend T::Sig

  # == Tests ==

  test "search scope uses the subject and description tsearch index" do # rubocop:disable Minitest/MultipleAssertions
    indexes = ActiveRecord::Base.connection.indexes(:whatsapp_groups)

    assert_includes indexes.map(&:name),
                    "index_whatsapp_groups_on_subject_description_tsearch"

    sql = WhatsappGroup.search("hangout").to_sql

    assert_match(/@@/, sql)
    assert_match(/setweight\(to_tsvector\('simple'/, sql)
    assert_match(/subject/, sql)
    assert_match(/description/, sql)
  end
end
