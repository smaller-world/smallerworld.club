# typed: true
# frozen_string_literal: true

require "image_processing/vips"

class ImageProcessing::Vips::Processor
  module PasskitWorldIcon
    extend T::Sig
    extend T::Helpers

    requires_ancestor { ImageProcessing::Vips::Processor }

    MASK_PATH = T.let(
      Rails.root.join("app/assets/images/world_card_pass_icon_mask.png").to_s,
      String,
    )

    def passkit_world_icon(size)
      resized = resize_to_fill(size, size)
      mask = T.unsafe(Vips::Image)
        .thumbnail(MASK_PATH, size, height: size, size: :force)
        .extract_band(0)
        .cast(:uchar)
      base = resized.has_alpha? ? resized.flatten : resized
      base.bandjoin(mask)
    end
  end

  prepend PasskitWorldIcon
end
