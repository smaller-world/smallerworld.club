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
          controller: "post-form haptic-bridge",
          post_form_world_key_labels_value: @world.key_labels.to_json,
          action: "turbo:submit-end->haptic-bridge#vibrate",
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
              action: "keydown.meta+enter->post-form#requestSubmit",
            },
          )
          f.error
        end
      end

      div(class: "flex flex-col gap-2", data: { controller: "transition-group" }) do
        unless @post.images.attached?
          Components::Button(
            variant: :outline,
            class: "self-center",
            data: {
              transition_group_target: "item",
              controller: "transition",
              action: "transition#leave transition:transitioned->transition-group#startNext",
              transition_leave: "transition-all duration-100 ease-out",
              transition_leave_end: "opacity-0 scale-95",
            },
          ) do |button|
            button.inline_start_icon("huge/image-01")
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

      Components::Card(size: :sm) do |card|
        card.content(class: "flex flex-col items-stretch gap-4") do
          field_for(form, :world_key_colors, class: "items-center") do |field|
            form.hidden_field(:world_key_colors, multiple: true, value: nil)

            field.checkbox_group(class: "flex-row justify-center") do |group|
              WorldKey.color.values.each do |color|
                group.field_label_for(
                  color,
                  class: "cursor-pointer w-auto not-has-data-checked:border-dashed",
                ) do |label|
                  label.field(class: "p-2") do |field|
                    field.content(class: "items-center") do
                      Icon(
                        "huge/key-02",
                        class: "size-4.5",
                        style: "color: var(--world-key-color-#{color})",
                      )
                    end
                    field.checkbox_group_item_for(
                      color,
                      hidden: true,
                      checked: checkbox_group_item_checked?(world_key_color: color),
                      input: {
                        data: {
                          post_form_target: "worldKeyColorsInput",
                          action: "change->post-form#updateWorldKeyColorsDescription",
                        },
                      },
                    )
                  end
                end
              end
            end
            field.description(
              class: "text-center text-xs empty:opacity-0 max-w-60 text-balance",
              data: {
                post_form_target: "worldKeyColorsDescription",
              },
            )
            field.error(class: "text-center text-xs")
          end

          submit_button_for(form, size: :lg) do |button|
            if @post.new_record?
              button.inline_start_icon("huge/mail-send-01")
              span { "submit post" }
            else
              button.inline_start_icon("huge/floppy-disk")
              span { "save changes" }
            end
          end
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

  sig { params(world_key_color: Enumerize::Value).returns(T::Boolean) }
  def checkbox_group_item_checked?(world_key_color:)
    if (colors = @post.world_key_colors)
      colors.include?(world_key_color)
    else
      true
    end
  end
end
