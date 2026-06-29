# typed: strict
# frozen_string_literal: true

class Smallerworld::Application
  sig { returns(String) }
  def passkit_pass_type_identifier
    credentials.passkit!.pass_type_identifier!
  end
end

# Configure Passkit models
Rails.application.configure do
  config.to_prepare do
    Passkit::Pass.has_many(
      :registrations,
      foreign_key: :passkit_pass_id,
      dependent: :destroy,
    )
    Passkit::Pass.has_many(
      :devices,
      through: :registrations,
    )

    Passkit::Device.has_many(
      :registrations,
      foreign_key: :passkit_device_id,
      dependent: :destroy,
    )
    Passkit::Device.has_many(
      :passes,
      through: :registrations,
    )
  end
end

# Autoload passes
Rails.autoloaders.main.push_dir(
  Rails.root.join("app/passkit"),
  namespace: Passkit,
)

if (credentials = Rails.application.credentials.passkit)
  ENV["PASSKIT_WEB_SERVICE_HOST"] = Rails.configuration.action_mailer
    .default_url_options
    .fetch_values(:protocol, :host).join("://")
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

  # Configure demo pass, dashboard auth
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

  # Add application passes
  # Rails.application.configure do
  #   config.after_initialize do
  #     Passkit.configure do |config|
  #       config.available_passes["Passes::WorldCard"] = -> {
  #         world = World.new(name: "testy's world")
  #         WorldCard.new(world:, granted_key_color: WorldKey.color.values.first)
  #       }
  #     end
  #   end
  # end
else
  ENV["SECRET_KEY_BASE_DUMMY"]
  ENV["PASSKIT_CERTIFICATE_KEY"] = "dummy"
  ENV["PASSKIT_APPLE_INTERMEDIATE_CERTIFICATE"] = "dummy"
  ENV["PASSKIT_PRIVATE_P12_CERTIFICATE"] = "dummy"
end
