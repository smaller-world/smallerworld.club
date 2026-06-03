# typed: strict
# frozen_string_literal: true

class Views::Home::Show < Views::Base
  # == Initialization ==

  sig { params(current_user: User).void }
  def initialize(current_user:)
    super()
    @current_user = current_user
    @friend_worlds = T.let(
      @current_user.accessible_worlds.with_attached_icon,
      World::PrivateAssociationRelation,
    )
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(display_header: true) do |layout|
      layout.page_container(
        class: "flex-1 max-w-lg flex flex-col gap-8 justify-center",
      ) do
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
                if @current_user.world_cards.exists?(world:)
                  Components::Button(
                    variant: :outline,
                    size: :icon_xs,
                    class: "rounded-full absolute -right-2 -top-2",
                  ) do
                    Icon("huge/cards-02", class: "size-4", data: {
                      controller: "tippy",
                      tippy_content_value: "you have a wallet card for #{world.name}!",
                    })
                  end
                end
              end
              span(class: "home-world-label", data: { size: "sm" }) do
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

        if hotwire_native_app?
          account_world_cards_form
        end
      end
    end
  end

  private

  sig { void }
  def account_world_cards_form
    form_with(
      url: account_world_cards_path,
      method: :put,
      scope: :user,
      data: {
        controller: "account-world-cards-form passes-bridge",
        action: "passes-bridge:received->account-world-cards-form#submitPasses",
      },
    ) do |form|
      template(data: { account_world_cards_form_target: "inputTemplate" }) do
        form.hidden_field(:world_card_pass_serial_numbers, multiple: true, value: nil)
      end

      @current_user.world_card_passes.pluck(:serial_number).each do |value|
        form.hidden_field(
          :world_card_pass_serial_numbers,
          multiple: true,
          value:,
          data: {
            account_world_cards_form_target: "existingInput",
          },
        )
      end
    end
  end
end
