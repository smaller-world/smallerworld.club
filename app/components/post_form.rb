# typed: true
# frozen_string_literal: true

class Components::PostForm < Components::Base
  # == Initialization ==

  sig { params(post: Post, options: T.untyped).void }
  def initialize(post:, **options)
    @post = post
    @world = T.let(post.world!, World)
    @options = options
    super()
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      model:,
      **mix(
        {
          class: "flex flex-col gap-6",
          data: {
            controller: "form",
          },
        },
        @options,
      ),
    ) do |form|
      div(class: "flex flex-col gap-4") do
        Components::FieldGroup(class: "flex-row gap-3") do
          field_for(form, :emoji, class: "flex-0") do |f|
            f.emoji_input(**f.error_tooltip_attributes)
          end
          field_for(form, :title, class: "flex-1") do |f|
            f.text_input(placeholder: "a title!")
            f.error
          end
        end
        field_for(form, :body) do |f|
          f.lexxy_editor(
            placeholder: "something i want to share...",
            required: true,
            class: "min-h-36",
            data: {
              action: "keydown.meta+enter->form#submit",
            },
          )
          f.error
        end
      end
      field_for(form, :images) do |f|
        f.label { "add up to 4 pics" }
        f.uppy_group(
          max_files: 4,
          allowed_file_types: [
            "image/png",
            "image/jpeg",
            "image/gif",
            "image/heic",
            "image/webp",
            "image/svg+xml",
            "image/avif",
          ],
          class: "grid grid-cols-2 mt-1",
          dropzone_class: "aspect-square",
          preview_fit: :contain,
        )
        f.error
      end
      submit_button_for(form) do |button|
        if @post.new_record?
          button.inline_start_icon("huge/mail-send-01")
          span { "submit" }
        else
          button.inline_start_icon("huge/floppy-disk")
          span { "save changes" }
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Object) }
  def model
    if @post.new_record?
      [ @world, @post ]
    else
      @post
    end
  end
end
