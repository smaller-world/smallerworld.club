# typed: strict
# frozen_string_literal: true

return if Rails.env.test?

ENV["PASSKIT_WEB_SERVICE_HOST"] = Rails.configuration.action_mailer
  .default_url_options
  .fetch_values(:protocol, :host).join("://")

if (credentials = Rails.application.credentials.passkit)
  ENV["PASSKIT_APPLE_TEAM_IDENTIFIER"] = credentials.apple_team_identifier
  ENV["PASSKIT_PASS_TYPE_IDENTIFIER"] = credentials.pass_type_identifier
  ENV["PASSKIT_CERTIFICATE_KEY"] = credentials.certificate_key
  if (certificate = credentials.apple_intermediate_certificate)
    path = Rails.root.join("tmp/passkit/apple_intermediate_certificate.cer")
    File.binwrite(path, Base64.decode64(certificate))
    ENV["PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE"] = path.to_s
  end
  if (certificate = credentials.private_p12_certificate)
    path = Rails.root.join("tmp/passkit/private_p12_certificate.p12")
    File.binwrite(path, Base64.decode64(certificate))
    ENV["PASSKIT_PRIVATE_P12_CERTIFICATE"] = path.to_s
  end
end

require "extensions/passkit/support_generation_without_barcodes"

# Configure demo pass, dashboard auth.
Passkit.configure do |config|
  config.available_passes["Passes::DemoPass"] = -> { nil }

  config.authenticate_dashboard_with do
    T.bind(self, Passkit::Dashboard::ApplicationController)

    unless Rails.env.development?
      raise ActionController::RoutingError,
        "Dashboard is not available"
    end
  end
end

# Add application passes.
Rails.application.configure do
  config.after_initialize do
    Passkit.configure do |config|
      config.available_passes["Passes::WorldCard"] = -> {
        world = World.new(name: "testy's world")
        WorldCard.new(world:, granted_key_color: WorldKey.color.values.first)
      }
    end
  end
end

module Passes; end

Rails.autoloaders.main.push_dir(Rails.root.join("app/passes"), namespace: Passes)
