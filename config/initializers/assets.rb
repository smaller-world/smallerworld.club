# typed: strict
# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Exclude JS source dirs from asset pipeline.
Rails.application.configure do
  config.after_initialize do
    excluded_paths = [
      Rails.root.join("app/javascript"),
      Rails.root.join("vendor/javascript"),
    ]
    config.assets.excluded_paths += excluded_paths
    config.assets.paths -= excluded_paths
    config.assets.precompile -= Turbo::Engine::PRECOMPILE_ASSETS
  end
end
