# typed: strict
# frozen_string_literal: true

class Views::Home::Show < Views::Base
  # == Initialization ==

  sig { params(current_user: User).void }
  def initialize(current_user:)
    super()
    @current_user = current_user
    @owned_worlds = T.let(
      @current_user.owned_worlds.chronological.with_attached_icon,
      World::PrivateAssociationRelation,
    )
    @accessible_worlds = T.let(
      @current_user.accessible_worlds.with_attached_icon,
      World::PrivateAssociationRelation,
    )
    @pending_world_invitations = T.let(
      @current_user.world_invitations.pending_acceptance
        .joins(world: [ icon_attachment: :blob ]),
      WorldInvitation::PrivateRelation,
    )
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      title: ("home" unless hotwire_native_app?),
      force_header: true,
    ) do |layout|
      show_alert = !hotwire_native_app?

      layout.page_container(class: "flex-1 max-w-lg flex flex-col") do
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
              appstore_listing_path,
              variant: :default,
              icon: "huge/app-store",
              class: "mt-1",
            )
          end
        end

        div(class: "flex-1 flex flex-col gap-8 justify-center") do
          owned_worlds
          accessible_worlds
        end

        if show_alert
          div(class: "flex-1 max-h-40 min-h-0 shrink")
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def owned_worlds
    ul(class: "flex gap-6 flex-wrap justify-center empty:hidden") do
      @owned_worlds.each do |world|
        li(class: "relative") do
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
        "hidden [ul:empty_+_&]:revert-display-layer",
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
      @accessible_worlds.each do |world|
        li do
          link_to(world, class: "world-icon-container hover:underline") do
            div(class: "relative") do
              image_tag(
                world.page_icon_variant,
                class: "world-icon",
                data: { world_icon_size: "sm" },
              )
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
        link_to("/scan_qr_code", class: "world-icon-container hover:underline") do
          Components::Button(
            element: :div,
            variant: :outline,
            class: "world-icon shadow-none border-dashed",
            data: { world_icon_size: "sm" },
          ) do
            Icon("huge/qr-code", class: "size-7 text-muted-foreground")
          end
          span(class: "world-icon-label text-xs text-muted-foreground") do
            "join friend's world"
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
  #       controller: "tippy",
  #       tippy_content_value: "you have a wallet card for #{world.name}!",
  #       action: "click->tippy#show:prevent:stop",
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
