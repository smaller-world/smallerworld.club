# typed: strict
# frozen_string_literal: true

class Components::PostForm < Components::Base
  # == Initialization ==

  sig { params(post: Post, attributes: T.untyped).void }
  def initialize(post:, **attributes)
    super(**attributes)
    @post = post
  end

  # == Component ==

  sig { override.void }
  def view_template
    world = @post.world!
    form_with(model:, **mix(
      {
        class: "flex flex-col gap-6",
        data: {
          controller: token_list(
            "submit haptic-bridge",
            # "post-draft" => @post.new_record?,
          ),
          action: [
            "turbo:submit-end->haptic-bridge#vibrate",
            "turbo:submit-end->post-draft#clear",
          ],
          post_draft_world_id_value: world.id,
        },
      },
      @attributes,
    )) do |form|
      div(class: "flex flex-col gap-4") do
        field_for(form, :type_id) do |f|
          f.select(class: "flex flex-col items-start") do |select|
            select.with_trigger(
              class: "border border-border bg-background hover:bg-muted hover:text-foreground dark:bg-transparent dark:hover:bg-input/30",
            ) do
              "post type"
            end
            select.with_content do |select_content|
              select_content.group do
                @post.world_post_types.each do |post_type|
                  select_content.item(value: post_type.id) do
                    div(class: "flex items-center gap-2") do
                      if (icon = post_type.icon)
                        Icon(icon)
                      end
                      span { post_type.label }
                    end
                  end
                end
              end
            end
          end
          f.error(class: "text-center")
        end

        Components::FieldGroup(class: "flex-row gap-3") do
          field_for(form, :emoji, class: "flex-0") do |f|
            f.emoji_input(**compact_mix(
              {
                data: {
                  action: "change->post-draft#save",
                },
              },
              error_tooltip_attributes_for(form, :emoji),
            ))
          end
          field_for(form, :title, class: "flex-1") do |f|
            f.text_input(
              placeholder: "a title!",
              data: {
                action: "change->post-draft#save",
              },
            )
            f.error
          end
        end
        field_for(form, :body) do |f|
          f.lexxy_editor(
            placeholder: "something i want to share...",
            required: true,
            class: "min-h-36",
            data: {
              action: [
                "lexxy:initialize->post-draft#restore",
                "lexxy:change->post-draft#save",
                "keydown.meta+enter->submit#request",
              ],
            },
          )
          f.description(class: "text-center text-xs mt-px") do
            "write freely! your posts are encrypted."
          end
          f.error(class: "text-center")
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
            data: {
              action: "change->post-draft#save",
            },
          )
          f.error
        end
      end

      div(class: "flex flex-col items-stretch gap-3") do
        Components::FieldSet(data: { action: "change->post-draft#save" }) do
          radio_group_for(form, :quiet, class: "grid-cols-2") do |radio_group|
            quiet_choice_card_for(:off, radio_group:) do |field|
              div(class: "flex items-center gap-1.5") do
                Icon("huge/notification-01", class: "size-3")
                field.title(class: "text-xs") { "post loudly" }
              end
              field.description(class: "text-xs leading-tight") do
                "send notifications"
              end
            end
            quiet_choice_card_for(:on, radio_group:, class: "border-dashed") do |field|
              div(class: "flex items-center gap-1.5") do
                Icon("huge/notification-snooze-01", class: "size-3")
                field.title(class: "text-xs") { "post quietly" }
              end
              field.description(class: "text-xs leading-tight ") do
                "no notifs + hide in tab"
              end
            end
          end
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

  private

  # == Helpers ==

  sig { returns(Object) }
  def model
    if @post.new_record?
      world = @post.world!
      [ world, @post ]
    else
      @post
    end
  end

  sig do
    params(form: PhlexRailsFormBuilder, field: Symbol)
      .returns(T.nilable(T::Hash[Symbol, T.untyped]))
  end
  def error_tooltip_attributes_for(form, field)
    if (messages = full_error_messages_for(form, field)) && (message = messages.first)
      {
        data: {
          controller: "tippy connection",
          tippy_content_value: message,
          tippy_placement_value: "bottom",
          action: "connection:connect->tippy#show",
        },
      }
    end
  end

  sig do
    params(
      value: Symbol,
      radio_group: Components::RadioGroup,
      attributes: T.untyped,
      content: T.proc.params(field: Components::Field).void,
    ).returns(T.untyped)
  end
  def quiet_choice_card_for(value, radio_group:, **attributes, &content)
    radio_group.field_label_for(
      value,
      **mix({ class: "cursor-pointer" }, attributes),
    ) do |field_label|
      field_label.field(orientation: :horizontal, class: "px-3 py-2") do |field|
        field.content(class: "flex flex-col gap-0.5") do
          yield(field)
        end
        field.radio_group_item_for(value, class: "visually-hidden")
      end
    end
  end

  # sig { params(form: PhlexRailsFormBuilder).void }
  # def key_colors_field_for(form)
  #   field_for(form, :key_colors, class: "items-center") do |field|
  #     form.hidden_field(:key_colors, multiple: true, value: nil)

  #     field.checkbox_group(class: "flex-row justify-center") do |group|
  #       WorldKey.color.values.each do |color|
  #         group.field_label_for(
  #           color,
  #           class: "cursor-pointer w-auto not-has-data-checked:border-dashed",
  #         ) do |label|
  #           label.field(class: "p-2") do |field|
  #             field.content(class: "items-center") do
  #               Icon(
  #                 "huge/key-02",
  #                 class: "size-4.5",
  #                 style: "color: var(--world-key-color-#{color})",
  #               )
  #             end
  #             field.checkbox_group_item_for(
  #               color,
  #               hidden: true,
  #               checked: checkbox_group_item_checked?(world_key_color: color),
  #               input: {
  #                 data: {
  #                   post_form_target: "worldKeyColorsInput",
  #                   action: "change->post-form#updateWorldKeyColorsDescription",
  #                 },
  #               },
  #             )
  #           end
  #         end
  #       end
  #     end
  #     field.description(
  #       class: "text-center text-xs empty:opacity-0 max-w-60 text-balance",
  #       data: {
  #         post_form_target: "worldKeyColorsDescription",
  #       },
  #     )
  #     field.error(class: "text-center text-xs")
  #   end
  # end
end
