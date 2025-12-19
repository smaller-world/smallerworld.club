# rubocop:disable Layout/LineLength
# typed: true
# frozen_string_literal: true

RailsIcons.configure do |config|
  config.icons_path = "app/assets/icons"
  config.default_library = "heroicons"

  config.libraries.heroicons.default_variant = :mini
  config.libraries.heroicons.exclude_variants = %i[ outline ]

  config.libraries.sidekickicons.default_variant = :mini
  config.libraries.sidekickicons.exclude_variants = %i[ outline ]

  config.libraries.phosphor.default_variant = :fill
  config.libraries.phosphor.exclude_variants = %i[
    bold duotone light regular thin
  ]

  config.libraries.tabler.default_variant = :filled
  config.libraries.tabler.exclude_variants = %i[ outline ]


  # config.default_variant = "" # Set a default variant for all libraries

  # Override Phosphor defaults
  # config.libraries.phosphor.default_variant = "" # Set a default variant for Phosphor
  # config.libraries.phosphor.exclude_variants = [:duotone, :thin] # Exclude specific variants

  # config.libraries.phosphor.bold.default.css = "size-6"
  # config.libraries.phosphor.bold.default.data = {}

  # config.libraries.phosphor.duotone.default.css = "size-6"
  # config.libraries.phosphor.duotone.default.data = {}

  # config.libraries.phosphor.fill.default.css = "size-6"
  # config.libraries.phosphor.fill.default.data = {}

  # config.libraries.phosphor.light.default.css = "size-6"
  # config.libraries.phosphor.light.default.data = {}

  # config.libraries.phosphor.regular.default.css = "size-6"
  # config.libraries.phosphor.regular.default.data = {}

  # config.libraries.phosphor.thin.default.css = "size-6"
  # config.libraries.phosphor.thin.default.data = {}

  # Override Heroicon defaults
  # config.libraries.heroicons.default_variant = "" # Set a default variant for Heroicons
  # config.libraries.heroicons.exclude_variants = [:mini, :micro] # Exclude specific variants

  # config.libraries.heroicons.outline.default.css = "size-6"
  # config.libraries.heroicons.outline.default.stroke_width = "1.5"
  # config.libraries.heroicons.outline.default.data = {}

  # config.libraries.heroicons.solid.default.css = "size-6"
  # config.libraries.heroicons.solid.default.data = {}

  # config.libraries.heroicons.mini.default.css = "size-5"
  # config.libraries.heroicons.mini.default.data = {}

  # config.libraries.heroicons.micro.default.css = "size-4"
  # config.libraries.heroicons.micro.default.data = {}

  # Override Tabler defaults
  # config.libraries.tabler.default_variant = "" # Set a default variant for Tabler
  # config.libraries.tabler.exclude_variants = [] # Exclude specific variants

  # config.libraries.tabler.regular.default.css = "size-6"
  # config.libraries.tabler.solid.default.css = "size-6"
  # config.libraries.tabler.solid.default.data = {}

  # config.libraries.tabler.outline.default.css = "size-6"
  # config.libraries.tabler.outline.default.stroke_width = "2"
  # config.libraries.tabler.outline.default.data = {}

  # Override Sidekickicons defaults
  # config.libraries.sidekickicons.default_variant = "" # Set a default variant for Sidekickicons
  # config.libraries.sidekickicons.exclude_variants = [:mini, :micro] # Exclude specific variants

  # config.libraries.sidekickicons.outline.default.css = "size-6"
  # config.libraries.sidekickicons.outline.default.stroke_width = "1.5"
  # config.libraries.sidekickicons.outline.default.data = {}

  # config.libraries.sidekickicons.solid.default.css = "size-6"
  # config.libraries.sidekickicons.solid.default.data = {}

  # config.libraries.sidekickicons.mini.default.css = "size-5"
  # config.libraries.sidekickicons.mini.default.data = {}

  # config.libraries.sidekickicons.micro.default.css = "size-4"
  # config.libraries.sidekickicons.micro.default.data = {}
end
