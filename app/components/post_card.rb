# typed: strict
# frozen_string_literal: true

class Components::PostCard < Components::Base
  # == Initialization ==

  sig do
    params(
      post: Post,
      replied: T::Boolean,
      async_reactions: T::Boolean,
      show_notification_prompt: T::Boolean,
      frame: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    post:,
    replied:,
    async_reactions: false,
    show_notification_prompt: false,
    frame: {},
    **attributes
  )
    super(**attributes)
    @post = post
    @replied = replied
    @async_reactions = async_reactions
    @show_notification_prompt = show_notification_prompt
    @frame_options = frame
    @post_type = T.let(@post.type!, PostType)
  end

  # == Component ==

  sig { override.void }
  def view_template
    turbo_frame_tag(@post, :card, target: "_top", **@frame_options) do
      Components::Card(size: :sm, **mix(
        {
          class: "post-card",
          data: {
            quiet: @post.quiet?,
          },
        },
        @attributes,
      )) do |card|
        card.header do
          card.description do
            div(class: "flex-1 flex items-center gap-2") do
              Components::Badge(variant: :secondary) do |badge|
                if (emoji = @post.emoji)
                  div(
                    class: "font-emoji text-md mr-0.5 align-baseline leading-none",
                    data: { icon: :inline_start },
                  ) do
                    emoji
                  end
                elsif (icon = @post_type.icon)
                  badge.inline_start_icon(icon)
                end
                span(class: "font-normal") { @post_type.label }
              end

              local_time(@post.created_at, class: "lowercase text-xs block")
            end

            if allowed_to?(:manage?, @post)
              div(class: "flex gap-1.5 items-center -my-1") do
                # world_key_badges
                edit_menu(card:)
              end
            end
          end
          if (title = @post.title)
            card.title { title }
          end
        end
        card.content do
          div(
            class: "post-body",
            data: {
              controller: "collapse",
            },
          ) do
            div(data: {
              collapse_target: "content",
              slot: "expand-content",
            }) do
              @post.body.to_s
            end
            div(data: { slot: "expand-control" }) do
              Components::Button(
                variant: :ghost,
                size: :sm,
                data: {
                  collapse_target: "control",
                  action: "collapse#trigger",
                },
              ) do |button|
                button.inline_start_icon("huge/unfold-more")
                span { "show more" }
              end
            end
          end
          if (images = @post.image_thumbnails.presence)
            Components::ImageStack(images:)
          end
        end

        card.footer do
          if allowed_to?(:reply?, @post)
            Components::ReplyInitiationForm(
              reply_initiation: @post.reply_initiations.build,
              replied: @replied,
            )
          elsif @show_notification_prompt
            notification_prompt_button
          end

          if @async_reactions
            Components::AsyncPostReactions(post: @post)
          else
            Components::PostReactions(post: @post)
          end
        end
      end

      turbo_stream_from(@post, hidden: true)
    end
  end

  private

  # == Helpers ==

  sig { params(card: Components::Card).void }
  def edit_menu(card:)
    Components::DropdownMenu() do |menu|
      menu.with_trigger_button(variant: :outline, size: :xs) do
        div(class: "relative h-full w-1.5") do
          div(class: "absolute bottom-0 top-0 -left-1.25 flex items-center") do
            Icon("huge/more-vertical", class: "size-3.5")
          end
        end
        span { "edit" }
      end

      menu.with_content(anchor: [ :bottom, :end ]) do |menu_content|
        menu_content.link_item_to([ :edit, @post ]) do
          Icon("huge/pencil-edit-01")
          span { "edit" }
        end
        form_with(
          url: @post,
          method: :delete,
          data: {
            controller: "haptic-bridge",
            action: "turbo:submit-end->haptic-bridge#vibrate",
          },
        ) do
          menu_content.button_item(
            type: :submit,
            variant: :destructive,
            data: {
              action: "dropdown-menu#preventAutoClose",
            },
          ) do
            Icon("huge/delete-01")
            span { "delete" }
          end
        end
      end
    end
  end

  sig { void }
  def notification_prompt_button
    Components::Button(
      class: "hidden",
      data: {
        controller: [
          "notification-permission-bridge",
          "notification-token-bridge",
          "transition",
          "tippy",
          "connection",
        ],
        transition_enter: "transition-[opacity,scale] ease-in-quart duration-200",
        transition_enter_start: "scale-95 opacity-0",
        tippy_content_value: "get notified when friends react!",
        tippy_trigger_value: "manual",
        tippy_placement_value: "bottom-start",
        tippy_flash_duration_value: 5000,
        tippy_flash_delay_value: 1000,
        action: [
          "notification-permission-bridge:pending-authorization->transition#enter",
          "transition:entered->tippy#flash",
          "notification-token-bridge#request",
        ],
      },
    ) do |button|
      button.inline_start_icon("huge/notification-01")
      span { "enable notifications" }
    end
  end
end
