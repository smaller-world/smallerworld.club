# frozen_string_literal: true

source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 7.1"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [ :windows, :jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Use Active Storage with S3-compatible services (Cloudflare R2)
gem "aws-sdk-s3", require: false

# Typecheck code at runtime
gem "sorbet-runtime"

# Perform full text search with Postgres
gem "pg_search", "~> 2.3"

# Inline CSS into email templates
gem "roadie-rails"

# Build views with Ruby
gem "phlex-rails", "~> 2.4"
gem "phlex-icons"

# Declare enum attributes with Enumerize
gem "enumerize", "~> 2.8"

# Create human-friendly identifiers for models
gem "friendly_id", "~> 5.6"

# Makes http fun again!
gem "httparty", "~> 0.24.2"

# Enforce a canonical host
gem "rack-canonical-host", "~> 1.3"

# Active Job dashboard
gem "mission_control-jobs"

# Paginate with Pagy
gem "pagy", "~> 43.2"

# Extend MVC to AI interactions
gem "activeagent", "~> 1.0"
gem "openai", "~> 0.49.0"

# Interact with LLMs using RubyLLM
gem "ruby_llm", "~> 1.13"

# Parse and format phone numbers with phonelib
gem "phonelib", "~> 0.10.16"

# Cache-friendly, client-side local time
gem "local_time"

# Log errors to Sentry
gem "sentry-rails"
gem "sentry-ruby"

# Safer hash traversal with dig!
gem "dig_bang"

# Automated post-deploy tasks
gem "after_party"

# Use the auto_link helper to automatically link URLs in text
gem "rails_autolink", "~> 1.1"

# Add PostGIS support
gem "activerecord-postgis-adapter"
gem "rgeo"

group :development, :test do
  # Run tests with Minitest
  gem "minitest", "~> 6.0.1"
  gem "minitest-mock", "~> 5.27"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [ :mri, :windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "8.0.4", require: false

  # Generate Sorbet types from Rails code
  gem "tapioca", require: false

  # Auto-detect and warn about N+1 queries
  gem "prosopite"
  gem "pg_query"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Linting with Rubocop
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-sorbet", require: false
  gem "rubocop-shopify", require: false
  gem "rubocop-minitest", require: false
  gem "ruby-lsp", require: false

  # Type checking with Sorbet
  gem "sorbet", require: false

  # Live-reload for Hotwire
  gem "hotwire-spark", "~> 0.1.13"

  # Improve Propshaft development performance
  gem "listen", require: false

  # Annotate models and routes
  gem "annotaterb", require: false

  # Generate a standard Rails Dockerfile
  gem "dockerfile-rails"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

group :production do
  # Fix request.ip and request.remote_ip in Rails when using Cloudflare
  gem "cloudflare-rails", "~> 7.0"
end
