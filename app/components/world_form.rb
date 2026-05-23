# typed: true
# frozen_string_literal: true

class Components::WorldForm < Components::Base
  # == Initialization ==

  sig { params(world: World, options: T.untyped).void }
  def initialize(world:, **options)
    @world = world
    @options = options
    super()
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      model: @world,
      class: "flex flex-col gap-y-4",
      **@options,
    ) do |form|
      field_for(form, :name) do |f|
        f.label { "name" }
        f.text_input(required: true)
        f.error
      end

      field_for(form, :icon, data: { controller: "field" }) do |f|
        f.label { "icon" }
        div(class: "flex flex-col items-center") do
          f.uppy_dnd(
            required: true,
            allowed_file_types: [
              "image/png",
              "image/jpeg",
              "image/gif",
              "image/heic",
              "image/webp",
              "image/svg+xml",
              "image/avif",
            ],
            crop_to_aspect_ratio: 1,
            dropzone_class: "size-40 rounded-world-icon",
            data: {
              action: "uppy:error->field#showError",
            },
          )
        end
        f.error(data: { field_target: "error" })
      end

      submit_button_for(form) do |button|
        if @world.new_record?
          button.inline_start_icon("huge/plus-sign-square")
          span { "create world" }
        else
          button.inline_start_icon("huge/floppy-disk")
          span { "save changes" }
        end
      end
    end
  end
end
