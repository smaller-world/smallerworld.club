# typed: true
# frozen_string_literal: true

require "active_storage/service/s3_service"

module ActiveStorage
  class Service::R2Service < ActiveStorage::Service::S3Service
    def initialize(custom_domain: nil, **args)
      # Required values for R2’s S3-compatible usage
      args[:force_path_style] = true
      args[:request_checksum_calculation] = "when_required"
      args[:response_checksum_validation] = "when_required"
      args[:region] = "auto"
      super(**T.unsafe(args))
      @custom_domain = custom_domain
    end

    def url(key, **options)
      if (domain = @custom_domain)
        URI.join(domain, key).to_s
      else
        super
      end
    end
  end
end
