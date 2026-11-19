# typed: strict
# frozen_string_literal: true

credentials = Rails.application.credentials.sentry

Sentry.init do |config|
  config.dsn = credentials&.dsn
  config.enabled_environments = [ "production" ]
  config.breadcrumbs_logger = [
    :sentry_logger,
    :http_logger,
    :active_support_logger,
  ]
  config.excluded_exceptions += [
    "ActiveSupport::MessageVerifier::InvalidSignature",
    "ActiveRecord::RecordNotUnique",
  ]

  # Automatically attach to Rails error reporter
  config.rails.register_error_subscriber = true

  # == Tracing ==
  config.traces_sample_rate = 0.0

  # == Data Collection ==
  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.data_collection.user_info = true
  config.data_collection.http_bodies = [
    :incoming_request,
    :outgoing_request,
    :incoming_response,
    :outgoing_response,
  ]
  config.data_collection.database_query_data = true
  config.data_collection.queues = true
  config.data_collection.cookies = true
  config.data_collection.url_query_params = true
end
