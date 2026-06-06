# typed: strict
# frozen_string_literal: true

# Override ImageProcessing's autoload for `Vips` so that our extension is
# loaded the first time `ImageProcessing::Vips` is referenced. This avoids
# requiring `ruby-vips` (and thus libvips) at boot — useful in CI contexts
# like `assets:precompile` where libvips is not installed.
ImageProcessing.autoload(
  :Vips,
  "extensions/image_processing/passkit_world_icon_transformation",
)
