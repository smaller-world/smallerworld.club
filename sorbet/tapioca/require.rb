# typed: strict
# frozen_string_literal: true

# require "active_support/testing/stream"
# require "rails/all"
# require "rails/generators"
# require "rails/generators/app_base"
# require "bundler/audit/task"
# require "annotate_rb"
# require "prosopite/middleware/rack"

require "sentry/rails/controller_transaction"
require "sentry/rails/controller_methods"
require "sentry/rails/overrides/streaming_reporter"

require "tapioca/dsl/compilers/active_record_relations"
require "tapioca/dsl/helpers/active_record_constants_helper"

require "active_record/railtie"
require "active_record/railties/controller_runtime"
require "active_record/connection_adapters/postgresql_adapter"

require "action_policy/rails/scope_matchers/active_record"
require "connection_pool"
