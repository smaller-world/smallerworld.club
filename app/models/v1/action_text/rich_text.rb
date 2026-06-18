# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: action_text_rich_texts
#
#  id          :uuid             not null, primary key
#  body        :text
#  name        :string           not null
#  record_type :string           not null
#  created_at  :timestamptz      not null
#  updated_at  :timestamptz      not null
#  record_id   :uuid             not null
#
# Indexes
#
#  index_action_text_rich_texts_uniqueness  (record_type,record_id,name) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
module V1
  module ActionText
    class RichText < V1::ApplicationRecord
      self.table_name = "action_text_rich_texts"

      # Mirrors what ::ActionText::RichText sets up, but routed through our
      # v1 connection + readonly? defenses inherited from V1::ApplicationRecord.
      serialize :body, coder: ::ActionText::Content
      belongs_to :record, polymorphic: true

      delegate :to_s,
        :nil?,
        :present?,
        :blank?,
        :to_plain_text,
        :to_trix_html,
        to: :body,
        allow_nil: true
    end
  end
end
