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
    config.x.site.description = "share your inner world with close friends"
    config.x.layout.confetti_canvas_id = "confetti_canvas"
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

    # == Shortlinking ==

    T::Sig::WithoutRuntime.sig do
      params(fallback_url_options: T::Hash[Symbol, T.untyped])
        .returns(T.all(GeneratedUrlHelpersModule, GeneratedPathHelpersModule))
    end
    def shortlinked_url_helpers(fallback_url_options = {})
      @shortlinked_url_helpers ||= T.let(
        if Rails.env.production?
          ShortlinkedUrlHelpers.new(protocol: "https", host: "smlr.world")
        else
          ShortlinkedUrlHelpers.new(**fallback_url_options)
        end,
        T.nilable(ShortlinkedUrlHelpers),
      )
    end

    # == Singletons ==

    sig { returns(Telnyx::Client) }
    def initialize_telnyx_client
      @telnyx_client = T.let(@telnyx_client, T.nilable(Telnyx::Client))
      @telnyx_client = Telnyx::Client.new(
        api_key: Rails.application.credentials.telnyx!.api_key!,
      )
    end

    sig { returns(Telnyx::Client) }
    def telnyx_client
      @telnyx_client ||= initialize_telnyx_client
    end

    sig { returns(Turnstile::Client) }
    def initialize_turnstile_client
      @turnstile_client = T.let(@turnstile_client, T.nilable(Turnstile::Client))
      @turnstile_client = Turnstile::Client.new
    end

    sig { returns(Turnstile::Client) }
    def turnstile_client
      @turnstile_client ||= initialize_turnstile_client
    end

    config.to_prepare do
      application = Smallerworld.application
      application.initialize_telnyx_client
      application.initialize_turnstile_client
    end
  end

  sig { returns(Smallerworld::Application) }
  def self.application
    T.cast(Rails.application, Smallerworld::Application)
  end
end
