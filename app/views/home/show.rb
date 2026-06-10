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
    @accessible_worlds = T.let(
      @current_user.accessible_worlds.with_attached_icon,
      World::PrivateAssociationRelation,
    )
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(display_header: true) do |layout|
      layout.page_container(class: "flex-1 max-w-lg flex flex-col gap-8") do
        unless hotwire_native_app?
          Components::Alert(class: "gap-y-1") do |alert|
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

        turbo_frame_tag(
          :your_worlds,
          target: "_top",
          class: "flex gap-6 flex-wrap justify-center",
        ) do
          @current_user.owned_worlds.each do |world|
            link_to(world, class: "world-icon-container hover:underline") do
              image_tag(world.page_icon_variant, class: "world-icon")
              span(class: "world-icon-label") do
                world.name
              end
            end
          end

          if @current_user.owned_worlds.empty?
            link_to(new_world_path, class: "world-icon-container hover:underline") do
              Components::Button(
                element: :div,
                variant: :outline,
                class: "home-world-icon border-dashed",
              ) do
                image_tag("logo.png", class: "size-12")
              end
              span(class: "world-icon-label") do
                "create your world"
              end
            end
          end
        end

        turbo_frame_tag(
          :other_worlds,
          class: "flex gap-4 flex-wrap justify-center",
          target: "_top",
        ) do
          @accessible_worlds.each do |world|
            link_to(
              world,
              class: "world-icon-container hover:underline",
            ) do
              div(class: "relative") do
                image_tag(
                  world.page_icon_variant,
                  class: "world-icon",
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
                      "huge/loyalty-card",
                      class: "text-muted-foreground size-4",
                    )
                  end
                end
              end
              span(class: "world-icon-label text-xs") do
                world.name
              end
            end
          end

          @world_cards_pending_key_creation&.each do |card|
            world = card.world!
            link_to(
              [ card, :key_grant ],
              class: "world-icon-container hover:underline",
            ) do
              div(class: "relative") do
                image_tag(
                  world.page_icon_variant,
                  class: "world-icon opacity-50",
                  data: { size: "sm" },
                )
                div(class: "absolute inset-0 flex items-center justify-center") do
                  Icon("huge/loyalty-card", class: "size-8 text-white")
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
                "scan to add friend"
              end
            end
          end

          unless @world_cards_pending_key_creation
            Components::DevicePassesForm(
              url: home_path,
              data: {
                turbo_frame: :other_worlds,
              },
            )
          end
        end
      end
    end
  end
end
