# typed: strict
# frozen_string_literal: true

class Components::PostForm < Components::Base
  # == Initialization ==

  sig do
    params(
      post: Post,
      restore_draft: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(post:, restore_draft: false, **attributes)
    super(**attributes)
    @post = post
    @restore_draft = restore_draft
    @post_type = T.let(@post.type!, PostType)
    @world = T.let(@post.world!, World)
  end

  # == Component ==

  sig { override.void }
  def view_template
    action = if @restore_draft
      restore_post_draft_path
    else
      @post.new_record? ? [ @world, @post ] : @post
    end
    Components::Form(
      @post,
      action:,
      id: "post_form",
      **mix(
        {
          class: "post-form",
          data: {
            restoring_draft: (true if @restore_draft),
            controller: token_list(
              "post-form-type submit haptic-bridge",
              "post-draft" => @post.new_record?,
            ),
            post_form_type_edit_url_template_value: edit_post_type_path(":post_type_id"),
            post_form_type_recipients_select_frame_url_template_value:
              post_recipients_select_path(":post_type_id"),
            post_draft_world_id_value: (@world.id if @post.new_record?),
            action: token_list(
              "turbo:submit-end->haptic-bridge#vibrate" => !@restore_draft,
              "turbo:submit-end->post-draft#clear" => @post.new_record? && !@restore_draft,
              "turbo:load@document->post-draft#restore" => @post.new_record? && @restore_draft,
            ),
          },
        },
        @attributes,
      ),
    ) do |form|
      div(class: "flex flex-col gap-4") do
        div(class: "flex gap-4 justify-between") do
          div(class: "flex gap-0.5") do
            form.wrapped(
              form.field(:type_id).select(
                @post.world_post_types.select(:id, :icon, :label),
                data: {
                  post_form_type_target: "select",
                  action: "change->post-form-type#update",
                },
              ) do |select|
                select.with_trigger do
                  "post type"
                end
                select.with_content do |select_content|
                  select_content.group do
                    select.options.each do |post_type|
                      select_content.item(
                        value: post_type.id,
                      ) do
                        div(class: "flex items-center gap-2") do
                          Icon(post_type.icon)
                          span { post_type.label }
                        end
                      end
                    end
                  end
                end
              end,
              label: false,
              error: false,
            )
            button_link_to(
              "edit",
              [ :edit, @post_type ],
              size: :sm,
              class: "text-muted-foreground font-normal px-2 mt-0.5",
              data: {
                post_form_type_target: "editAnchor",
                controller: "redirect-back-to-self",
                action: "redirect-back-to-self#visit:prevent",
              },
            )
          end

          unless @restore_draft
            turbo_frame_tag(
              "recipients_select",
              data: {
                post_form_type_target: "recipientsSelectFrame",
              },
            ) do
              form.wrapped(
                form.field(:recipient_ids).post_recipients_select(**T.unsafe({
                  post: @post,
                  **form.error_tooltip_attributes_for(:recipient_ids),
                })),
                orientation: :horizontal,
                label: false,
                error: false,
              )
            end
          end
        end

        Components::FieldGroup(class: "flex-row gap-3") do
          form.wrapped(
            form.field(:emoji).emoji(**mix(
              form.error_tooltip_attributes_for(:emoji),
              ({ data: { action: "change->post-draft#save" } } if can_save_draft?),
            )),
            label: false,
            error: false,
            class: "flex-0",
          )
          form.wrapped(
            form.field(:title).text(placeholder: "a title!", data: {
              action: ("change->post-draft#save" if can_save_draft?),
            }),
            label: false,
            class: "flex-1",
          )
        end

        Components::Field(invalid: form.invalid?(:body)) do |field|
          form.Field(:body).lexxy(
            placeholder: "something i want to share...",
            required: !@restore_draft,
            class: "min-h-36",
            data: {
              action: token_list(
                "keydown.meta+enter->submit#request",
                "lexxy:change->post-draft#save" => can_save_draft?,
              ),
            },
          )
          field.description(
            data: {
              post_draft_target: "savedTimestampLabel",
            },
          ) do
            "write freely! your posts are encrypted."
          end
          form.error_for(:body, class: "text-center")
        end
      end

      div(class: "flex flex-col gap-2", data: { controller: "transition-group" }) do
        unless @post.images.attached?
          Components::Button(
            type: :button,
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

        form.wrapped(
          form.field(:images).uppy_group(
            value: @post.ordered_images_blobs,
            max_number_of_files: 4,
            allowed_file_types: [
              "image/png",
              "image/jpeg",
              "image/gif",
              "image/heic",
              "image/webp",
              "image/svg+xml",
              "image/avif",
            ],
            preview_fit: :contain,
            class: "grid grid-cols-2 mt-1",
            dropzone_class: "aspect-square",
            data: {
              action: token_list(
                "uppy:error->field-error#show",
                "uppy:uploaded->post-draft#save" => can_save_draft?,
                "uppy-group:removed->post-draft#save" => can_save_draft?,
              ),
            },
          ),
          label: "add up to 4 pics",
          error: {
            data: {
              field_error_target: "error",
            },
          },
          class: class_names("hidden" => !@post.images.attached?),
          data: {
            transition_group_target: "item",
            controller: "field-error transition",
            action: "transition-group:start->transition#enter",
            transition_enter: "transition-all duration-200 ease-in",
            transition_enter_start: "opacity-0 scale-95",
          },
        )
      end

      div(class: "flex flex-col items-stretch gap-3") do
        if @post.new_record?
          form.Field(:quiet).radios(
            [ [ false, :loud ], [ true, :quiet ] ],
            class: "grid-cols-2",
          ) do |choice|
            choice.label(class: "cursor-pointer") do
              Components::Field(
                orientation: :horizontal,
                invalid: form.invalid?(:quiet),
                class: "px-3 py-2",
              ) do |field|
                field.content(class: "flex flex-col gap-0.5") do
                  div(class: "flex items-center gap-1.5") do
                    icon = if choice.item == :loud
                      "huge/notification-01"
                    else
                      "huge/notification-snooze-01"
                    end
                    Icon(icon, class: "size-3")
                    field.title(class: "text-xs") do
                      plain("post ")
                      plain(choice.item == :loud ? "loudly" : "quietly")
                    end
                  end
                  field.description(class: "text-xs leading-tight") do
                    if choice.item == :loud
                      "send notifications"
                    else
                      "no notifs + hide in tab"
                    end
                  end
                end
                choice.input(class: "visually-hidden", data: {
                  action: ("post-draft#save" if can_save_draft?),
                })
              end
            end
          end
        else
          Components::Field(
            orientation: :horizontal,
            invalid: form.invalid?(:quiet),
            class: "justify-center",
          ) do
            form.Field(:quiet).checkbox
            form.Field(:quiet).label(class: "post-form-checkbox-label") do
              "hide post in #{@post_type.label} tab"
            end
          end
        end

        form.submit(size: :lg) do |button|
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

  sig { returns(T::Boolean) }
  def can_save_draft?
    @post.new_record? && !@restore_draft
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
