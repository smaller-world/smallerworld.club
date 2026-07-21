# typed: strict
# frozen_string_literal: true

class Views::Worlds::Show < Views::Base
  # == Initialization ==

  sig do
    params(
      current_user: User,
      world: World,
      only_post_type: T.nilable(PostType),
      only_favorited: T::Boolean,
      celebrate: T::Boolean,
      new_post_dialog_open: T::Boolean,
    ).void
  end
  def initialize(
    current_user:,
    world:,
    only_post_type:,
    only_favorited:,
    celebrate:,
    new_post_dialog_open:
  )
    super()
    @current_user = current_user
    @world = world
    @only_post_type = only_post_type
    @only_favorited = only_favorited
    @celebrate = celebrate
    @new_post_dialog_open = new_post_dialog_open

    @owner = T.let(@world.owner!, User)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: @world.name) do |app_layout|
      app_layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        navigation_buttons

        if @current_user == @owner
          v1_post_import_frame
        elsif (own_worlds = @current_user
            .owned_worlds_without_key_or_invitation_for(@owner)
            .to_a
            .presence) &&
            # If the owner is already invited to one of the user's worlds, don't show this
            # alert.
            own_worlds.size == @current_user.owned_worlds.size
          send_own_world_invitation_alert(own_worlds:)
        elsif (current_device = @current_device) && !@current_device.push_token?
          enable_notifications_alert(current_device:)
        end

        div(class: "flex flex-col gap-6") do
          section(class: "flex flex-col items-center gap-2") do
            div(class: "relative") do
              image_tag(
                @world.page_icon_variant,
                id: dom_id(@world, :page_icon),
                class: "world-icon size-32",
                data: {
                  turbo_permanent: true,
                  controller: "confetti connection",
                  confetti_emoji_value: "🎉",
                  confetti_canvas_id_value: Rails.configuration.confetti_canvas_id,
                  connection_delay_value: 1000,
                  action: ("turbo:load@document->confetti#launch" if @celebrate),
                },
              )
              if allowed_to?(:manage?, @world)
                Components::WorldKeyGrantIconButton(world: @world)
              end
            end
            h1(class: "text-2xl text-center") do
              @world.name
            end
            if (blurb = @world.blurb)
              p(class: "whitespace-pre-wrap text-center text-muted-foreground text-sm") do
                auto_link(blurb, html: {
                  class: "underline underline-offset-4",
                  target: "_blank",
                  rel: "noopener noreferrer nofollow",
                }) do |text|
                  # Normalize URL (strip protocol)
                  Addressable::URI.parse(text).omit(:scheme).to_s.delete_prefix("//")
                end
              end
            end
          end

          if allowed_to?(:manage?, @world)
            section(class: "flex gap-2 justify-center") do
              Components::NewPostDialog(
                world: @world,
                open: @new_post_dialog_open,
              ) do |dialog|
                dialog.with_trigger_button(
                  size: :lg,
                  class: "world-action-button group/new-post-button relative",
                  data: {
                    controller: "post-draft-info",
                    post_draft_info_world_id_value: @world.id,
                    action: "user-focus:active@document->post-draft-info#update",
                  },
                ) do |button|
                  button.inline_start_icon(
                    "huge/quill-write-02",
                    class: "group-data-draft-available/new-post-button:hidden",
                  )
                  button.inline_start_icon(
                    "huge/more-horizontal-circle-02",
                    class: "hidden group-data-draft-available/new-post-button:revert-display-layer",
                  )
                  span { "new post" }
                end
              end
              button_link_to(
                "your friends",
                [ @world, :keys ],
                variant: :outline,
                size: :lg,
                icon: "huge/user-group",
                class: "world-action-button",
              )
            end
          end
        end

        div(class: "flex flex-col gap-4") do
          Components::WorldPostFiltersForm(
            world: @world,
            currently_showing_favorited: @only_favorited,
            current_post_type: @only_post_type,
          )

          turbo_frame_tag(
            dom_id(@world, :posts),
            src: [
              @world,
              :posts,
              type_id: @only_post_type&.id,
              only_ravorited: (true if @only_favorited),
            ],
            target: "_top",
            class: "world-posts-frame",
            data: {
              controller: "frame-reload",
              turbo_permanent: (true if hotwire_native_app?),
            },
          ) do
            div(class: "space-y-4") do
              3.times do
                Components::PostCardSkeleton()
              end
            end
          end
        end
      end

      Components::AccountAppVisitForm(current_user: @current_user)
      if @world_key
        Components::WorldKeyWorldVisitForm(world_key: @world_key)
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(WorldKey)) }
  def world_key
    @world_key = T.let(
      @world.keys.find_by(recipient: @current_user),
      T.nilable(WorldKey),
    )
  end

  sig { void }
  def navigation_buttons
    div(class: "flex gap-6 justify-between", hidden: hotwire_native_app?) do
      button_back_to(:home, variant: :secondary)

      if allowed_to?(:manage?, @world)
        button_link_to(
          "edit",
          [ :edit, @world ],
          icon: "huge/pencil-edit-01",
          variant: :secondary,
          data: {
            controller: "button-bridge",
          },
        )
      elsif (world_key = self.world_key)
        button_link_to(
          "settings",
          world_key,
          variant: :secondary,
          icon: "huge/settings-01",
          data: {
            controller: "button-bridge",
            bridge_ios_image: "gearshape.fill",
          },
        )
      end
    end
  end

  sig { void }
  def v1_post_import_frame
    if @owner.has_v1_account?
      turbo_frame_tag(
        :v1_posts_import,
        src: [ @world, :v1_posts_import ],
        class: "empty:hidden pb-2",
        data: {
          controller: "frame-reload frame-reset user-focus",
        },
      )
      turbo_stream_from(@world, :v1_posts_import, hidden: true)
    end
  end

  sig { params(own_worlds: T::Array[World]).void }
  def send_own_world_invitation_alert(own_worlds:)
    Components::Alert(class: "flex flex-col") do |alert|
      alert.title do
        "you can see #{@owner.name}'s posts, but #{@owner.name} can't see yours!"
      end
      description_html = capture do
        alert.description(class: "text-end") do
          "give #{@owner.name} a key to your world?"
        end
      end
      primary_world, *other_worlds = own_worlds
      if other_worlds.none?
        link_to(
          [ :new, primary_world, :invitation, recipient_id: @owner.id ],
          class: "underline underline-offset-4",
          data: {
            controller: "redirect-back-to-self",
            action: "redirect-back-to-self#visit",
          },
        ) do
          raw(description_html) # rubocop:disable Rails/OutputSafety
        end
      else
        Components::Dialog() do |dialog|
          dialog.with_trigger do
            button(
              data: { action: "dialog#open" },
              class: "text-muted-foreground underline self-end",
            ) do
              raw(description_html) # rubocop:disable Rails/OutputSafety
            end
          end
          dialog.with_content do |dialog_content|
            dialog_content.header do |dialog_header|
              dialog_header.title do
                "give #{@owner.name} a key to your world!"
              end
            end

            div(class: "space-y-3") do
              div(class: "text-sm") do
                "pick the world you'd like to invite #{@owner.name} to:"
              end
              Components::ItemGroup() do |group|
                own_worlds.each do |world|
                  group.item(
                    element: :a,
                    href: url_for([
                      :new,
                      world,
                      :invitation,
                      recipient_id: @owner.id,
                    ]),
                    variant: :outline,
                    size: :sm,
                    data: {
                      controller: "redirect-back-to-self",
                      action: "redirect-back-to-self#visit",
                    },
                  ) do |item|
                    item.media(variant: :image, class: "size-14 rounded-world-icon") do
                      image_tag(world.page_icon_variant)
                    end
                    item.content(class: "gap-0.5") do |item_content|
                      item_content.title(class: "text-base font-heading") do
                        world.name
                      end
                      if (blurb = world.blurb)
                        item_content.description(class: "text-xs") do
                          blurb
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  sig { params(current_device: Device).void }
  def enable_notifications_alert(current_device:)
    Components::Alert(class: "gap-2") do |alert|
      Icon("huge/notification-01")
      alert.title do
        "get notified with #{@owner.name} posts!!"
      end
      Components::Form(
        current_device,
        action: device_push_token_path,
        method: :put,
        class: "flex flex-col items-end",
        data: {
          controller: "device-push-token-form",
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
            ],
            action: [
              "notification-token-bridge#request:prevent",
              "notification-token-bridge:retrieved->device-push-token-form#setInputValueAndSubmit",
            ],
          },
        ) do |button|
          button.inline_start_icon("huge/love-korean-finger")
          span { "enable notifications" }
        end
      end
    end
  end

  # sig { params(cards: WorldCard::PrivateRelation).void }
  # def unclaimed_world_cards(cards)
  #   Components::ItemGroup(
  #     class: "hidden",
  #     data: {
  #       controller: "transition-group transition connection",
  #       transition_group_target: "item",
  #       transition_enter: "transition-[max-height] duration-400 ease-in-quart",
  #       transition_enter_start: "max-h-0",
  #       transition_enter_end: "max-h-[1000px]",
  #       action: [
  #         "transition:transitioned->transition-group#startNext",
  #         "connection:connect->transition#enter",
  #       ],
  #     },
  #   ) do
  #     cards.find_each do |card|
  #       Components::Item(
  #         variant: :muted,
  #         size: :sm,
  #         class: "gap-y-2 hidden [&.hidden]:scale-95",
  #         data: {
  #           hidden_inline: true,
  #           transition_group_target: "item",
  #           controller: "transition",
  #           transition_enter: "transition-[opacity,scale] ease-in",
  #           transition_enter_start: "scale-95",
  #           action: [
  #             "transition-group:start->transition#enter",
  #             "transition:transitioned->transition-group#startNext",
  #           ],
  #         },
  #       ) do |item|
  #         item.media do
  #           Icon("huge/loyalty-card", class: "size-5")
  #         end
  #         item.content(class: "gap-0") do
  #           item.title do
  #             "you have an unlinked card for #{@world.name}"
  #           end
  #           item.description(class: "flex gap-1") do
  #             plain("card id:")
  #             span(class: "font-mono") { card.short_id }
  #           end
  #         end
  #         item.actions(class: "mx-auto") do
  #           form_with(model: [ :claim, card ], method: :post) do |form|
  #             submit_button_for(form, size: :sm) do |button|
  #               button.inline_start_icon("huge/link-01")
  #               span { "claim card" }
  #             end
  #           end
  #         end
  #       end
  #     end
  #   end if cards.any?
  # end

  # sig { params(card: WorldCard).void }
  # def card_icon_button(card)
  #   Components::Button(
  #     variant: :outline,
  #     size: :icon_sm,
  #     class: [
  #       "bg-muted rounded-full absolute -right-2.5 -top-2.5",
  #       "hidden with-pass-bridge:revert-display-layer",
  #     ],
  #     data: {
  #       controller: "pass-bridge",
  #       pass_bridge_pass_type_identifier_value:
  #         Smallerworld.application.passkit_pass_type_identifier,
  #       pass_bridge_serial_number_value: card.pass!.serial_number,
  #       action: "pass-bridge#open",
  #     },
  #   ) do
  #     Icon(
  #       "huge/loyalty-card",
  #       class: "text-muted-foreground",
  #     )
  #   end
  # end
end
