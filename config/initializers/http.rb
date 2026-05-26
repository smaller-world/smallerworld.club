# typed: strict
# frozen_string_literal: true

HTTP.default_options = HTTP::Options.new(features: {
  logging: {
    logger: Rails.logger,
  },
})
