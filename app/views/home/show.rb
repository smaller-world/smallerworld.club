# typed: strict
# frozen_string_literal: true

class Views::Home::Show < Views::Base
  # == Initialization ==

  sig do
    params(
      current_user: User,
      world_cards_pending_key_creation: T.nilable(WorldCard::PrivateRelation),
    ).void
  end
  def initialize(current_user:, world_cards_pending_key_creation:)
    super()
    @current_user = current_user
    @world_cards_pending_key_creation = world_cards_pending_key_creation
    @friend_worlds = T.let(
      @current_user.accessible_worlds.with_attached_icon,
      World::PrivateAssociationRelation,
    )
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(display_header: true) do |layout|
      layout.page_container(class: "flex-1 max-w-lg flex flex-col gap-8 justify-center") do
        div(class: "flex gap-6 flex-wrap justify-center") do
          @current_user.owned_worlds.each do |world|
            link_to(world, class: "home-world-link") do
              image_tag(
                world.page_icon_variant,
                class: "home-world-icon",
              )
              span(class: "home-world-label") do
                world.name
              end
            end
          end

          if @current_user.owned_worlds.empty?
            link_to(new_world_path, class: "home-world-link") do
              Components::Button(
                element: :div,
                variant: :outline,
                class: "home-world-icon border-dashed",
              ) do
                image_tag("logo.png", class: "size-12")
              end
              span(class: "home-world-label") do
                "create your world"
              end
            end
          end
        end

        div(class: "flex gap-4 flex-wrap justify-center") do
          @friend_worlds.each do |world|
            link_to(world, class: "home-world-link", data: { size: "sm" }) do
              div(class: "relative") do
                image_tag(
                  world.page_icon_variant,
                  class: "home-world-icon",
                  data: { size: "sm" },
                )
                if @current_user.world_cards.active.exists?(world:)
                  Components::Button(
                    element: :div,
                    variant: :outline,
                    size: :icon_xs,
                    class: "bg-muted rounded-full absolute -right-2 -top-2",
                    data: {
                      controller: "tippy",
                      tippy_content_value: "you have a wallet card for #{world.name}!",
                      action: "click->tippy#show:prevent:stop",
                    },
                  ) do
                    Icon(
                      "huge/cards-02",
                      class: "text-muted-foreground size-4",
                    )
                  end
                end
              end
              span(class: "home-world-label", data: { size: "sm" }) do
                world.name
              end
            end
          end

          @world_cards_pending_key_creation&.each do |card|
            world = card.world!
            grant = world.key_grant(color: card.granted_key_color)
            link_to(
              world_key_grant_path(grant, card_id: card.id),
              class: "home-world-link",
              data: { size: "sm" },
            ) do
              div(class: "relative") do
                image_tag(
                  world.page_icon_variant,
                  class: "home-world-icon opacity-50",
                  data: { size: "sm" },
                )
                div(class: "absolute inset-0 flex items-center justify-center") do
                  Icon("huge/key-02", class: "size-8 text-white")
                end
              end
              span(class: "home-world-label text-foreground/50", data: { size: "sm" }) do
                world.name
              end
            end
          end

          if hotwire_native_app?
            link_to(
              "/scan_qr_code",
              class: "home-world-link",
              data: {
                size: "sm",
              },
            ) do
              Components::Button(
                element: :div,
                variant: :outline,
                class: "home-world-icon shadow-none border-dashed",
              ) do
                Icon("huge/qr-code", class: "size-7 text-muted-foreground")
              end
              span(class: "home-world-label font-normal") do
                "scan to add friend"
              end
            end
          end
        end
      end

      unless @world_cards_pending_key_creation
        Components::DevicePassesForm(url: home_path)
      end
    end
  end
end
