# typed: strict
# frozen_string_literal: true

class Components::PostCard < Components::Base
  include Phlex::Rails::Helpers::FormWith

  # == Initialization ==

  sig do
    params(
      current_user: User,
      post: Post,
      replied: T::Boolean,
      newly_created: T::Boolean,
      async_reactions: T::Boolean,
      frame: T::Hash[Symbol, T.untyped],
      attributes: T.untyped,
    ).void
  end
  def initialize(
    current_user:,
    post:,
    replied:,
    newly_created: false,
    async_reactions: false,
    frame: {},
    **attributes
  )
    super(**attributes)
    @current_user = current_user
    @post = post
    @newly_created = newly_created
    @replied = replied
    @async_reactions = async_reactions
    @frame_options = frame
    @post_type = T.let(@post.type!, PostType)
  end

  # == Component ==

  sig { override.void }
  def view_template
    turbo_frame_tag(@post, :card, target: "_top", **@frame_options) do
      Components::Card(size: :sm, **mix({ class: "post-card" }, @attributes)) do |card|
        card.header do
          card.description do
            div(class: "flex-1 flex items-center gap-x-2 gap-y-1 flex-wrap") do
              Components::Badge(variant: :outline, class: "text-muted-foreground") do |badge|
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

              time(
                class: "lowercase text-xs block",
                data: {
                  controller: "post-timestamp",
                  post_timestamp_datetime_value: @post.created_at.iso8601,
                },
              )
            end

            if allowed_to?(:manage?, @post)
              div(class: "flex items-center gap-0.5") do
                button_link_to(
                  "edit",
                  [ :edit, @post ],
                  variant: :secondary,
                  size: :xs,
                  icon: "huge/pencil-edit-01",
                )

                favorite_button
              end
            end
          end
          if (title = @post.title)
            card.title { title }
          end
        end
        card.content do
          div(
            class: "post-card-body",
            data: {
              slot: "post-card-body",
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
          if (images = @post.ordered_images_thumbnails.presence)
            Components::ImageStack(images:)
          end
        end

        card.footer do
          if @async_reactions
            Components::AsyncPostReactions(post: @post)
          else
            Components::PostReactions(post: @post)
          end

          if @current_user != @post.world_owner!
            Components::ReplyInitiationForm(
              reply_initiation: @post.reply_initiations.build,
              replied: @replied,
            )
          elsif @newly_created &&
              (current_device = Current.device) && !current_device.push_token?
            enable_notifications_button(current_device:)
          end
        end
      end

      turbo_stream_from(@post, hidden: true)
    end
  end

  private

  # == Helpers ==

  sig { void }
  def favorite_button
    action = @post.favorited? ? :unfavorite : :favorite
    form_with(model: [ action, @post ], method: :post, data: {
      controller: "haptic-bridge",
      action: "turbo:submit-end->haptic-bridge#vibrate",
    }) do
      Components::Button(
        type: :submit,
        variant: :ghost,
        size: :icon_xs,
        class: "post-card-favorite-button",
        data: {
          favorited: ("" if @post.favorited?),
        },
      ) do
        Icon("huge/star")
      end
    end
  end

  # sig { params(card: Components::Card).void }
  # def edit_menu(card:)
  #   Components::DropdownMenu() do |menu|
  #     menu.with_trigger_button(variant: :outline, size: :xs) do
  #       div(class: "relative h-full w-1.5") do
  #         div(class: "absolute bottom-0 top-0 -left-1.25 flex items-center") do
  #           Icon("huge/more-vertical", class: "size-3.5")
  #         end
  #       end
  #       span { "edit" }
  #     end

  #     menu.with_content(anchor: [ :bottom, :end ]) do |menu_content|
  #       menu_content.link_item_to([ :edit, @post ]) do
  #         Icon("huge/pencil-edit-01")
  #         span { "edit" }
  #       end
  #       form_with(
  #         url: @post,
  #         method: :delete,
  #         data: {
  #           controller: "haptic-bridge",
  #           action: "turbo:submit-end->haptic-bridge#vibrate",
  #         },
  #       ) do
  #         menu_content.button_item(
  #           type: :submit,
  #           variant: :destructive,
  #           data: {
  #             action: "dropdown-menu#preventAutoClose",
  #           },
  #         ) do
  #           Icon("huge/delete-01")
  #           span { "delete" }
  #         end
  #       end
  #     end
  #   end
  # end

  sig { params(current_device: Device).void }
  def enable_notifications_button(current_device:)
    Components::Form(
      current_device,
      action: device_push_token_path,
      method: :put,
      data: {
        controller: "device-push-token-form",
        action: "turbo:submit-end->frame-reload#reload",
      },
    ) do |form|
      form.Field(:push_token).hidden(data: {
        device_push_token_form_target: "input",
      })
      form.submit(
        data: {
          controller: [
            "notification-permission-bridge",
            "notification-token-bridge",
            "transition",
            "tooltip",
            "connection",
          ],
          transition_enter: "transition-[opacity,scale] ease-in-quart duration-200",
          transition_enter_start: "scale-95 opacity-0",
          tooltip_content_value: "get notified when friends react!",
          tooltip_trigger_value: "manual",
          tooltip_placement_value: "bottom-start",
          tooltip_flash_duration_value: 5000,
          tooltip_flash_delay_value: 1000,
          action: [
            "notification-token-bridge#request:prevent",
            "notification-token-bridge:retrieved->device-push-token-form#setInputValueAndSubmit",
            "notification-token-bridge:retrieved->transition#enter",
            "transition:entered->tooltip#flash",
          ],
        },
      ) do |button|
        button.inline_start_icon("huge/notification-01")
        span { "enable notifications" }
      end
    end
  end
end
