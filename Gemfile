# rubocop:disable Layout/LineLength

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.8"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1"

# JSON-backed, nestable models
gem "store_model", "~> 1.6"

# Use PostgreSQL as the database for Active Record
gem "pg", "~> 1.5"

# Perform full text search with Postgres
gem "pg_search", "~> 2.3"

# Enable additional operators and utilities for Active Record with PostgreSQL
gem "active_record_extended",
    github: "GeorgeKaraszi/ActiveRecordExtended",
    ref: "fe0e094"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 7.1"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Use Good Job as the backend for Active Job
gem "good_job", "~> 4.7.0"

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
# gem "solid_cache"
# gem "solid_queue"
# gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.12"
gem "ruby-vips", "~> 2.2", require: false

# Use S3 as the backend for Active Storage
gem "aws-sdk-s3", "~> 1.208", require: false

# Send emails with Mailjet
gem "mailjet", "~> 1.7"

# Use FriendlyId to create human-friendly identifiers for models
gem "friendly_id", "~> 5.5"

# Modern concurrency tools
gem "concurrent-ruby", "~> 1.1"

# Use Faraday to make HTTP requests
gem "faraday", "~> 2.10"

# Show a healthcheck route
gem "rails-healthcheck"

# Silence logs from certain actions
gem "silencer", "~> 2.0", require: false

# Validate emails, phone numbers, dates, arrays, and more
gem "can_has_validations", "~> 1.8"
gem "email_validator", "~> 2.2"
gem "phonelib", "~> 0.10.10"
gem "validate_url", "~> 1.0"
gem "date_validator", "~> 0.12.0"
gem "active_storage_validations", "~> 0.9.6"

# Load environment variables from .env
gem "dotenv", "~> 2.7", require: false

# Parse and manipulate URIs
gem "addressable", "~> 2.8"

# Handle soft deletions with Discard
gem "discard", "~> 1.4"

# Typecheck code at runtime
gem "sorbet-runtime"

# Use Enumerize to enumerate attributes
gem "enumerize", "~> 2.8"

# Use Action Policy to authorize actions
gem "action_policy", "~> 0.6.5"

# Serve and bundle frontend with Vite
gem "vite_rails", "~> 3.0"

# Use Inertia framework for server-driven SPAs
gem "inertia_rails", "~> 3.10.0"

# Use Premailer to inline CSS into email templates
gem "premailer-rails"

# Use Sentry for error reporting
gem "sentry-rails"
gem "stackprof"

# Run post-deploy tasks with after_party
gem "after_party"

# Handle CORS requests
gem "rack-cors", "~> 2.0"

# Cache counts in models with CounterCulture
gem "counter_culture", "~> 3.5"

# Serialize JSON with MultiJSON
gem "multi_json"

# Access YAML records
gem "frozen_record"

# Fast JSON serialization
gem "oj_serializers", "~> 2.0"

# Generate Typescript from serializers
gem "types_from_serializers", "~> 2.1"

# Paginate records with Pagy
gem "pagy", "~> 43.2"

# Send web push notifications
gem "web-push", "~> 3.0"

# Up-to-date Emoji Regex
gem "unicode-emoji", "~> 3.7", require: "unicode/emoji"

# Verify JWTs
gem "jwt", "~> 2.9"

# Parse HTML with Nokogiri
gem "nokogiri", "~> 1.15"

# Convert HTML to plain text
gem "html2text", "~> 0.4.0"

# Generate fake data
gem "faker", "~> 3.5"

# Count words
gem "words_counted", "~> 1.0"

# Send SMS with Twilio
gem "twilio-ruby", "~> 7.5"

# Manage money with Money Rails
gem "money-rails", "~> 1.15"

# Fetch Spotify metadata
gem "rspotify", "~> 2.12"

# Use Turbo drive and Hotwire
gem "turbo-rails", "~> 2.0"

# Use lexxy to edit rich text
gem "lexxy", "~> 0.1.23.beta"

# Use icons from Heroicons, Lucide, etc.
gem "rails_icons", "~> 1.5"

# Display local time in the browser
gem "local_time", "~> 3.0"

# Send native push notifications
gem "action_push_native", "~> 0.3.0"

# Detect device name
gem "device_detector", "~> 1.1"

# Generate QR codes
gem "rqrcode", "~> 3.2"

# Build HTML and SVG view components in Ruby
gem "phlex-rails", "~> 2.4"

group :development, :test do
  # Debug code with debug
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Auto-detect and warn about N+1 queries
  gem "prosopite"
  gem "pg_query"

  # Generate Typescript path helpers
  gem "js_from_routes", "~> 4.0"

  # Use Rubocop to lint code
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-sorbet", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-capybara", require: false
  gem "ruby-lsp", require: false
end

group :development do
  # Run git hooks with Lefthook
  gem "lefthook", "~> 1.7", require: false

  # Patch-level verification for Bundler
  gem "bundler-audit", "~> 0.9.2", require: false

  # Detect file changes for live reload
  gem "listen", "~> 3.8"

  # Wipe out inconsistent DB and schema.rb when switching branches
  gem "actual_db_schema", "~> 0.7.9"

  # Provide Rails context to AI agents
  gem "rails-mcp-server", "~> 1.5"

  # Rerun programs when files change
  gem "rerun", "~> 0.14.0", require: false

  # Typecheck code
  gem "sorbet", require: false
  gem "spoom", require: false
  gem "tapioca", require: false

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Display better error pages during development
  gem "better_errors"

  # Annotate models and routes
  gem "annotaterb", require: false

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem "rack-mini-profiler"
  gem "memory_profiler"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "capybara-playwright-driver"
  gem "rack-test"
end

group :production do
  # Fix request.ip and request.remote_ip in Rails when using Cloudflare
  gem "cloudflare-rails", "~> 7.0"
end
