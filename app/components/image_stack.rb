# typed: strict
# frozen_string_literal: true

class Components::ImageStack < Components::Base
  Image = T.type_alias do
    T.any(ActiveStorage::Blob, ActiveStorage::VariantWithRecord)
  end

  # == Initialization ==

  sig do
    params(
      images: T::Enumerable[Image],
      max_height: Integer,
      flip_boundary: Integer,
      attributes: T.untyped,
    ).void
  end
  def initialize(images:, max_height: 360, flip_boundary: 100, **attributes)
    super(**attributes)
    @images = T.let(images.to_a, T::Array[Image])
    @max_height = max_height
    @flip_boundary = flip_boundary
  end

  # == Component ==

  sig { override.void }
  def view_template
    root_element(
      :div,
      class: "image-stack",
      data: {
        controller: "image-stack lightbox",
        image_stack_max_height_value: @max_height,
        image_stack_flip_boundary_value: @flip_boundary,
      },
    ) do
      @images.each do |image|
        blob = image.is_a?(ActiveStorage::Blob) ? image : image.blob
        metadata = blob.metadata
        image_tag(
          image,
          width: metadata["width"],
          height: metadata["height"],
          draggable: false,
          class: class_names(
            "image-stack-image",
            "touch-none" => @images.size > 1,
          ),
          data: {
            lightbox_src: rails_representation_path(blob),
            image_stack_target: "image",
            lightbox_target: "image",
            action: token_list(
              "load->image-stack#relayout:once",
              "image-stack:click->lightbox#open",
              "pointerdown->image-stack#startDrag:prevent",
              "pointerup->image-stack#endDrag",
              "pointercancel->image-stack#endDrag",
            ),
          },
        )
      end
    end
  end
end
