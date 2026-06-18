# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: active_storage_blobs
#
#  id           :uuid             not null, primary key
#  byte_size    :bigint           not null
#  checksum     :string
#  content_type :string
#  filename     :string           not null
#  key          :string           not null
#  metadata     :text
#  service_name :string           not null
#  created_at   :timestamptz      not null
#
# Indexes
#
#  index_active_storage_blobs_on_key  (key) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
module V1
  module ActiveStorage
    class Blob < V1::ApplicationRecord
      self.table_name = "active_storage_blobs"

      has_many :attachments,
        class_name: "V1::ActiveStorage::Attachment",
        inverse_of: :blob,
        dependent: :destroy

      # All v1 blobs live in the :tigris service, regardless of what the
      # service_name column says.
      def service
        ::ActiveStorage::Blob.services.fetch(:tigris)
      end

      # Re-implement the bits of ::ActiveStorage::Blob we care about for
      # reading bytes. Avoids inheriting from the framework class (which
      # would bypass our V1 connection + readonly?).
      def download(&block)
        service.download(key, &block)
      end

      def url(expires_in: 5.minutes, disposition: :inline, filename: nil)
        service.url(
          key,
          expires_in:,
          disposition:,
          filename: filename || ::ActiveStorage::Filename.new(self.filename.to_s),
          content_type:,
        )
      end
    end
  end
end
