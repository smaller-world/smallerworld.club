# typed: true
# frozen_string_literal: true

# Add your extra requires here (`bin/tapioca require` can be used to bootstrap
# this list)

require "tapioca/dsl/helpers/active_record_constants_helper"
require "active_storage/service/s3_service"

ENV["PASSKIT_PRIVATE_P12_CERTIFICATE"] = "dummy"
ENV["PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE"] = "dummy"
ENV["PASSKIT_CERTIFICATE_KEY"] = "dummy"
require "passkit/generator"

# To type the correct superclass for Superform::Rails::Form
module Components
  class Base < Phlex::HTML; end
end
