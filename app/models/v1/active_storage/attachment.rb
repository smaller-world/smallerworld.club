# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: active_storage_attachments
#
#  id          :uuid             not null, primary key
#  name        :string           not null
#  record_type :string           not null
#  created_at  :timestamptz      not null
#  blob_id     :uuid             not null
#  record_id   :uuid             not null
#
# Indexes
#
#  index_active_storage_attachments_on_blob_id  (blob_id)
#  index_active_storage_attachments_uniqueness  (record_type,record_id,name,blob_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (blob_id => active_storage_blobs.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
module V1
  module ActiveStorage
    class Attachment < V1::ApplicationRecord
      self.table_name = "active_storage_attachments"

      belongs_to :blob,
        class_name: "V1::ActiveStorage::Blob",
        inverse_of: :attachments
      belongs_to :record, polymorphic: true

      delegate :download, :url, :filename, :content_type, :byte_size, to: :blob
    end
  end
end
