# typed: strict
# frozen_string_literal: true

class Views::Worlds::Show < Views::Base
  # == Initialization ==

  sig do
    params(
      current_user: User,
      world: World,
      new_post_modal_open: T::Boolean,
      celebrate: T::Boolean,
      post_type: T.nilable(PostType),
      created_post_id: T.nilable(String),
    ).void
  end
  def initialize(
    current_user:,
    world:,
    new_post_modal_open:,
    celebrate:,
    post_type:,
    created_post_id:
  )
    super()
    @current_user = current_user
    @world = world
    @new_post_modal_open = new_post_modal_open
    @celebrate = celebrate
    @post_type = post_type
    @created_post_id = created_post_id
    @owner = T.let(@world.owner!, User)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: @world.name) do |layout|
      layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        div(class: "flex gap-8 justify-between", hidden: hotwire_native_app?) do
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
          elsif allowed_to?(:show?, @world, with: WorldSettingsPolicy)
            button_link_to(
              "settings",
              [ @world, :settings ],
              variant: :secondary,
              icon: "huge/settings-01",
              data: {
                controller: "button-bridge",
                bridge_ios_image: "gearshape.fill",
              },
            )
          end
        end

        if allowed_to?(:manage?, @world)
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
          # else
          #   turbo_frame_tag(
          #     :unclaimed_world_card_notice,
          #     target: "_top",
          #     class: "empty:hidden has-[>_form]:hidden",
          #   ) do
          #     if (cards = @unclaimed_world_cards)
          #       unclaimed_world_cards(cards)
          #     else
          #       Components::DevicePassesForm(url: @world, data: {
          #         turbo_frame: :unclaimed_world_card_notice,
          #       })
          #     end
          #   end
        end

        div(class: "flex flex-col gap-6") do
          section(class: "flex flex-col items-center gap-2") do
            div(class: "relative") do
              image_tag(
                @world.page_icon_variant,
                class: "world-icon size-32",
                data: {
                  controller: "confetti connection",
                  confetti_emoji_value: "🎉",
                  confetti_canvas_id_value: Rails.configuration.confetti_canvas_id,
                  connection_delay_value: 1000,
                  action: ("connection:connect->confetti#launch" if @celebrate),
                },
              )
              Components::WorldKeyGrantIconButton(world: @world)
            end
            h1(class: "text-2xl text-center") do
              @world.name
            end
            if (blurb = @world.blurb)
              p(class: "whitespace-pre-wrap text-center text-muted-foreground text-sm") do
                blurb
              end
            end
          end

          if allowed_to?(:manage?, @world)
            section(class: "flex gap-2 justify-center") do
              new_post_button
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
          Components::WorldPostTypeForm(world: @world, post_type: @post_type)

          turbo_frame_tag(
            :posts,
            src: [
              @world,
              :posts,
              type_id: @post_type&.id,
              created_post_id: @created_post_id,
            ],
            target: "_top",
            class: "world-posts-frame",
            data: {
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
    end
  end

  private

  # == Helpers ==

  sig { void }
  def new_post_button
    Components::Dialog(open: @new_post_modal_open) do |dialog|
      dialog.with_trigger_button(
        size: :lg,
        class: "world-action-button",
      ) do |button|
        button.inline_start_icon("huge/quill-write-02")
        span { "new post" }
      end
      dialog.with_content do |dialog_content|
        dialog_content.header do |dialog_header|
          dialog_header.title do
            "what do you want to make?"
          end
        end
        Components::ItemGroup() do |item_group|
          @world.post_types.each do |post_type|
            div(class: "flex items-center gap-1") do
              item_group.item(
                element: :a,
                href: url_for([ :new, @world, :post, type_id: post_type.id ]),
                variant: :outline,
                size: :sm,
                data: {
                  action: "dialog#close",
                },
              ) do |item|
                if (icon = post_type.icon)
                  item.media(variant: :icon) do
                    Icon(icon)
                  end
                end
                item.content do
                  item.title do
                    post_type.label
                  end
                end
              end
              button_link_to("edit", [ :edit, post_type ], size: :sm)
            end
          end

          div

          item_group.item(
            element: :a,
            href: url_for([ :new, @world, :post_type ]),
            variant: :muted,
            size: :sm,
          ) do |item|
            item.content(class: "gap-0") do
              item.title do
                "something else!"
              end
              item.description do
                "create your own post type"
              end
            end
          end
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
