# typed: strict
# frozen_string_literal: true

class Views::Home::Show < Views::Base
  # == Initialization ==

  sig { params(current_user: User).void }
  def initialize(current_user:)
    super()
    @current_user = current_user
    @owned_worlds = T.let(
      @current_user.owned_worlds
        .chronological
        .with_attached_icon,
      World::PrivateAssociationRelation,
    )
    @world_keys = T.let(
      @current_user
        .world_keys
        .order_by_latest_visible_post
        .with_world_and_attached_icon,
      WorldKey::PrivateAssociationRelation,
    )
    @pending_world_invitations = T.let(
      @current_user.world_invitations
        .pending_acceptance
        .with_world_and_attached_icon,
      WorldInvitation::PrivateRelation,
    )

    @transition_enter = T.let(
      "transition-[scale,opacity] duration-300 ease-in-quart",
      String,
    )
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      title: ("home" unless hotwire_native_app?),
      force_header: true,
    ) do |app_layout|
      show_alert = !hotwire_native_app?

      app_layout.page_container(class: "flex-1 max-w-lg flex flex-col") do
        if show_alert
          Components::Alert(class: "gap-y-1 mb-6") do |alert|
            alert.title do
              "please try our app!!"
            end
            alert.description do
              "it looks like you're using smaller world in the browser. to get the " \
                "best experience, please download our app. thank you :)"
            end
            button_link_to(
              "get the app!",
              installation_instructions_path,
              variant: :default,
              icon: "huge/app-store",
              class: "mt-1",
            )
          end
        end

        div(
          class: class_names(
            "flex-1 flex flex-col gap-8 justify-center",
            "mt-4" => !show_alert,
          ),
          data: {
            controller: "transition-group connection",
            transition_group_item_delay_value: 100,
            action: "connection:connect->transition-group#start",
          },
        ) do
          owned_worlds
          accessible_worlds
        end

        if show_alert
          div(class: "flex-1 max-h-40 min-h-0 shrink")
        end
      end

      div(class: [
        "absolute top-[env(safe-area-inset-top,0px)] right-[env(safe-area-inset-right,0px)]",
        "flex items-center",
      ]) do
        button_link_to(
          edit_account_path,
          variant: :ghost,
          size: :icon,
          icon: "huge/settings-01",
          class: "mt-2 mr-6 [&>svg]:size-5 text-muted-foreground",
        )
      end

      Components::AccountAppVisitForm(current_user: @current_user)
    end
  end

  private

  # == Helpers ==

  sig { params(world_key: WorldKey).returns(Integer) }
  def badge_count_for(world_key)
    badge_counts_by_world_key_id.fetch(world_key.id, 0)
  end

  # Counts new visible posts for every one of the current user's world keys in a
  # single grouped query, avoiding an N+1 across `@world_keys`. Mirrors
  # `WorldKey#new_visible_world_posts_since_last_visited`: only posts of granted
  # post types, not hidden from the recipient, created after each key was last
  # visited.
  sig { returns(T::Hash[String, Integer]) }
  def badge_counts_by_world_key_id
    @badge_counts_by_world_key_id ||= T.let(
      PostTypeGrant
        .joins(:world_key, post_type: :posts)
        .where(world_keys: { recipient: @current_user })
        .where.not("world_keys.recipient_id = ANY(posts.hidden_from_ids)")
        .where(
          "world_keys.world_last_visited_at IS NULL OR " \
            "posts.created_at > world_keys.world_last_visited_at",
        )
        .group("world_keys.id")
        .count,
      T.nilable(T::Hash[String, Integer]),
    )
  end

  sig { void }
  def owned_worlds
    ul(class: "flex gap-6 flex-wrap justify-center empty:hidden") do
      @owned_worlds.each do |world|
        li(class: "relative starting:opacity-0 starting:scale-95 hidden", data: {
          transition_group_target: "item",
          controller: "transition",
          transition_enter: @transition_enter,
          action: [
            "transition-group:start->transition#enter",
            "transition-group:start->transition-group#startNext",
          ],
        }) do
          link_to(world, class: "world-icon-container hover:underline") do
            image_tag(world.page_icon_variant, class: "world-icon")
            span(class: "world-icon-label") do
              world.name
            end
          end
          Components::WorldKeyGrantIconButton(world:)
        end
      end
    end

    link_to(
      new_world_path,
      class: [
        "mx-auto world-icon-container hover:underline",
        "hidden [ul:empty+&]:revert-display-layer",
      ],
    ) do
      Components::Button(
        element: :div,
        variant: :outline,
        class: "world-icon border-dashed",
      ) do
        image_tag("logo.png", class: "size-12")
      end
      span(class: "world-icon-label shimmer shimmer-repeat-delay-2000") do
        "create your world"
      end
    end
  end

  sig { void }
  def accessible_worlds
    ul(class: "flex gap-4 flex-wrap justify-center") do
      @world_keys.each do |world_key|
        world = world_key.world!
        badge_count = badge_count_for(world_key)
        li(class: "hidden starting:opacity-0 starting:scale-95", data: {
          transition_group_target: "item",
          controller: "transition",
          transition_enter: @transition_enter,
          action: [
            "transition-group:start->transition#enter",
            "transition-group:start->transition-group#startNext",
          ],
        }) do
          link_to(world, class: "world-icon-container hover:underline") do
            div(class: "relative") do
              image_tag(
                world.page_icon_variant,
                class: "world-icon",
                data: { world_icon_size: "sm" },
              )
              if badge_count > 0
                Components::Badge(class: "absolute -top-1.5 -right-1.5 px-1 min-w-5") do
                  badge_count
                end
              end
            end
            span(class: "world-icon-label text-xs") do
              world.name
            end
          end
        end
      end

      @pending_world_invitations.find_each do |invitation|
        world = invitation.world!
        link_to(invitation, class: "world-icon-container hover:underline") do
          div(class: "relative") do
            image_tag(
              world.page_icon_variant,
              class: "world-icon opacity-50",
              data: { world_icon_size: "sm" },
            )
            div(class: "absolute inset-0 flex items-center justify-center") do
              Icon("huge/key-01", class: "size-8 text-white")
            end
          end
          span(class: "world-icon-label text-xs text-muted-foreground") do
            world.name
          end
        end
      end

      if hotwire_native_app?
        link_to(
          "/scan_qr_code",
          class: [
            "world-icon-container hover:underline",
            "hidden starting:scale-95 starting:opacity-0",
          ],
          data: {
            transition_group_target: "item",
            controller: "transition",
            transition_enter: @transition_enter,
            action:
              "transition-group:start->transition#enter",
          },
        ) do
          Components::Button(
            element: :div,
            variant: :outline,
            class: "world-icon shadow-none border-dashed",
            data: {
              world_icon_size: "sm",
            },
          ) do
            Icon("huge/qr-code", class: "size-7 text-muted-foreground")
          end
          span(class: "world-icon-label text-xs text-muted-foreground") do
            "join a friend's world"
          end
        end
      end
    end
  end

  # sig { params(world: World).returns(T.nilable(String)) }
  # def active_card_id_for(world)
  #   @active_card_ids_by_world_id ||= T.let(
  #     WorldCard.active
  #       .where(cardholder: @current_user, world: accessible_worlds)
  #       .order(:world_id, created_at: :desc)
  #       .pluck(Arel.sql("DISTINCT ON (world_id) world_id"), :id)
  #       .to_h,
  #     T.nilable(T::Hash[String, String]),
  #   )
  #   @active_card_ids_by_world_id[world.id]
  # end

  # sig { params(world: World, card_id: String).void }
  # def card_icon_button(world:, card_id:)
  #   Components::Button(
  #     element: :div,
  #     variant: :outline,
  #     size: :icon_xs,
  #     class: "bg-muted rounded-full absolute -right-2 -top-2",
  #     data: {
  #       controller: "tooltip",
  #       tooltip_content_value: "you have a wallet card for #{world.name}!",
  #       action: "click->tooltip#show:prevent:stop",
  #     },
  #   ) do
  #     Icon(
  #       "huge/loyalty-card",
  #       class: "text-muted-foreground size-4",
  #     )
  #   end
  # end

  # sig { returns(T.nilable(WorldCard::PrivateRelation)) }
  # def world_cards_pending_key_creation
  #   @world_cards_pending_key_creation&.each do |card|
  #     world = card.world!
  #     link_to(
  #       [ card, :key_grant ],
  #       class: "world-icon-container hover:underline",
  #     ) do
  #       div(class: "relative") do
  #         image_tag(
  #           world.page_icon_variant,
  #           class: "world-icon opacity-50",
  #           data: { size: "sm" },
  #         )
  #         div(class: "absolute inset-0 flex items-center justify-center") do
  #           Icon("huge/loyalty-card", class: "size-8 text-white")
  #         end
  #       end
  #       span(class: "world-icon-label text-xs text-muted-foreground") do
  #         world.name
  #       end
  #     end
  #   end
  # end
end
