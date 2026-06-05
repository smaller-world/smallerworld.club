# typed: strict
# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Configure RubyLLM before Rails::Application is inherited
#
# See: https://rubyllm.com/configuration/#initializer-load-timing-issue-with-use_new_acts_as
#
# TODO: Remove after upgrading to RubyLLM 2.0 (currently unreleased as of
# 2026-03-06)
RubyLLM.configure do |config|
  config.use_new_acts_as = true
end

module Smallerworld
  extend T::Sig

  class Application < Rails::Application
    extend T::Sig

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(8.1)

    # == Custom Configuration ==

    config.x.site.name = "smaller world"
    config.x.site.tagline = "share your inner world with close friends"
    config.x.layout.confetti_canvas_id = "confetti_canvas"

    config.fly_url = "https://fly.io/apps/smallerworld"
    config.logs_url = "https://fly-metrics.net/d/fly-logs/fly-logs?orgId=256205&var-app=smallerworld"
    config.metrics_url = "https://fly-metrics.net/d/fly-app/fly-app?orgId=256205&var-app=smallerworld"
    config.sentry_url = "https://smallerworld.sentry.io/issues/?limit=5&project=4511453980327936&query=error.unhandled%3Atrue%20is%3Aunresolved&sort=freq&statsPeriod=14d"
    config.testflight_url = "https://testflight.apple.com/join/n6v7J3Nd"
    # config.x.instagram_url = "https://instagram.com/smallerworld"
    # config.x.appleid.signin_scope = "email name"

    # == Rails Configuration ==

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: [ "assets", "tasks", "extensions" ])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Disable HTTP basic auth for the jobs dashboard
    config.mission_control.jobs.http_basic_auth_enabled = false

    # Set a PID file
    config.solid_queue.supervisor_pidfile = Rails.root.join("tmp/pids/jobs.pid")

    # == Custom Helpers ==

    sig { returns(String) }
    def site_name
      Rails.configuration.x.site.name or raise "Missing site name"
    end
  end

  sig { returns(Smallerworld::Application) }
  def self.application
    T.cast(Rails.application, Smallerworld::Application)
  end
end
