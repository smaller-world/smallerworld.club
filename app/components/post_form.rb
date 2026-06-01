# typed: strict
# frozen_string_literal: true

class Components::PostForm < Components::Base
  # == Initialization ==

  sig { params(post: Post, attributes: T.untyped).void }
  def initialize(post:, **attributes)
    super(**attributes)
    @post = post
    @world = T.let(post.world!, World)
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(model:, **mix(
      {
        class: "flex flex-col gap-6",
        data: {
          controller: "form",
        },
      },
      @attributes,
    )) do |form|
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
              action: "keydown.meta+enter->form#requestSubmit",
            },
          )
          f.error
        end
      end

      div(class: "flex flex-col gap-2", data: { controller: "transition-group" }) do
        unless @post.images.attached?
          Components::Button(
            variant: :outline,
            class: "self-center rounded-full px-3",
            data: {
              transition_group_target: "item",
              controller: "transition",
              action: "transition#leave transition:transitioned->transition-group#startNext",
              transition_leave: "transition-all duration-100 ease-out",
              transition_leave_end: "opacity-0 scale-95",
            },
          ) do
            Icon("huge/image-01")
            span { "add pics" }
          end
        end

        field_for(
          form,
          :images,
          class: class_names("hidden" => !@post.images.attached?),
          data: {
            transition_group_target: "item",
            controller: "transition",
            action: "transition-group:start->transition#enter",
            transition_enter: "transition-all duration-200 ease-in",
            transition_enter_start: "opacity-0 scale-95",
          },
        ) do |f|
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
      end

      submit_button_for(form, size: :lg) do |button|
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
