# typed: true
# frozen_string_literal: true

canonical_host = ENV["CANONICAL_HOST"] or return

Rails.application.config.middleware.use(
  Rack::CanonicalHost,
  canonical_host,
  cache_control: "no-cache",
  if: ->(uri) {
    # Ignore healthcheck requests
    uri.path != "/up"
  },
)
