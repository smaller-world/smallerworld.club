# typed: true
# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Configure RubyLLM before Rails::Application is inherited
#
# TODO: Remove after upgrading to RubyLLM 2.0 (currently unreleased as of
# 2026-03-06)
RubyLLM.configure do |config|
  config.use_new_acts_as = true
end

module HappyTown
  extend T::Sig

  class Application < Rails::Application
    extend T::Sig

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(8.1)

    # == Custom Configuration ==

    # == Site
    config.x.site_name = "happy town"
    config.x.site_tagline = "a home for third-space hosts and guests"
    config.x.site_description =
      "a new kind of third space in toronto. weekly walks, irl chat groups, " \
        "and hobby tables for curious, friendly people who like wandering " \
        "conversations."

    # == Socials
    config.x.luma_url = "https://luma.com/happytown"
    config.x.instagram_url = "https://instagram.com/happytown.to"
    config.x.tiktok_url = "https://tiktok.com/@adamdriversbod"

    # == Luma
    config.x.fairgrounds_tag_id = "tag-Tq68aDbM8T9R2Bj"
    config.x.mindful_miles_tag_id = "tag-XRCUFkgLqcr3E0l"

    # == WhatsApp
    config.x.whatsapp_user_lid = "189971403149563@lid"
    config.x.perform_whatsapp_deliveries = false

    # == Webhook Forwarding
    config.x.dev_server_url_options = {
      protocol: "https",
      host: "kaibook.itskai.me",
    }

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

    # == Singletons ==

    sig { returns(WaSenderApi) }
    def wa_sender_api
      return @wa_sender_api if defined?(@wa_sender_api)

      api_key = credentials.dig(:wa_sender_api, :api_key) or
        raise "Missing WA Sender API key"
      @wa_sender_api = WaSenderApi.new(api_key:)
    end

    # sig { returns(OpenRouter) }
    # def open_router
    #   return @open_router if defined?(@open_router)

    #   api_key = credentials.dig(:open_router, :api_key) or
    #     raise "Missing OpenRouter API key"
    #   @open_router = OpenRouter.new(api_key:)
    # end
  end

  sig { returns(HappyTown::Application) }
  def self.application
    T.cast(Rails.application, HappyTown::Application)
  end
end
