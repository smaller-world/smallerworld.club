# typed: strict
# frozen_string_literal: true

class Views::Worlds::Show < Views::Base
  # == Initialization ==

  sig do
    params(
      world: World,
      unclaimed_world_cards: T.nilable(WorldCard::PrivateRelation),
      celebrate: T::Boolean,
    ).void
  end
  def initialize(
    world:,
    unclaimed_world_cards:,
    celebrate: false
  )
    @world = world
    @unclaimed_world_cards = unclaimed_world_cards
    @celebrate = celebrate
    @keys = T.let(
      if (user = Current.user)
        @world.keys.accepted.where(recipient: user).to_a
      else
        []
      end,
      T::Array[WorldKey],
    )
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: @world.name) do |layout|
      layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        div(class: "flex gap-6 justify-between", hidden: hotwire_native_app?) do
          button_back_to(:home)

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
          elsif @keys.any? # TODO: Represent on mobile
            button_link_to(
              "settings",
              [ @world, :settings ],
              icon: "huge/settings-01",
              variant: :secondary,
              data: {
                controller: "button-bridge",
                bridge_ios_image: "gearshape.fill",
              },
            )
          end
        end

        unless allowed_to?(:manage?, @world)
          turbo_frame_tag(
            :unclaimed_world_card_notice,
            target: "_top",
            class: "empty:hidden has-[>_form]:hidden",
          ) do
            if (cards = @unclaimed_world_cards)
              unclaimed_world_cards(cards)
            else
              Components::DevicePassesForm(url: @world, data: {
                turbo_frame: :unclaimed_world_card_notice,
              })
            end
          end
        end

        section(class: "flex flex-col items-center gap-2") do
          image_tag(
            @world.page_icon_variant,
            class: "world-icon size-32",
            data: {
              controller: "confetti connection",
              confetti_emoji_value: "🎉",
              confetti_canvas_id_value:
                Rails.configuration.x.layout.confetti_canvas_id,
              connection_delay_value: 1000,
              action: ("connection:connect->confetti#launch" if @celebrate),
            },
          )
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
            button_link_to(
              "new post",
              [ :new, @world, :post ],
              variant: :default,
              size: :lg,
              icon: "huge/quill-write-02",
              class: "world-action-button",
            )
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

        turbo_frame_tag(
          :posts,
          src: [ @world, :posts ],
          target: "_top",
          data: {
            turbo_permanent: true,
            controller: "frame",
            action: "turbo:reload@document->frame#reloadAndPreserveScroll",
          },
        ) do
          div(class: "space-y-4") do
            10.times do
              Components::Card(class: "shadow-sm") do |card|
                card.header do
                  card.description do
                    span(class: "skeleton") do
                      "timestamp"
                    end
                  end
                  card.title do
                    span(class: "skeleton") do
                      "post title placeholder"
                    end
                  end
                end
                card.content(class: "flex flex-col gap-4") do
                  1..2.times do
                    p(class: "skeleton h-24")
                  end
                end
                card.footer(class: "flex justify-center") do
                  Components::Button(class: "skeleton") do
                    "placeholder"
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(key: WorldKey).returns(String) }
  def key_descriptor(key)
    color = key.color
    if color.match?(/^[aeiou]/i)
      "an #{color} key"
    else
      "a #{color} key"
    end
  end

  sig { params(cards: WorldCard::PrivateRelation).void }
  def unclaimed_world_cards(cards)
    Components::ItemGroup(
      class: "hidden",
      data: {
        controller: "transition-group transition connection",
        transition_group_target: "item",
        transition_enter: "transition-[max-height] duration-400 ease-in-quart",
        transition_enter_start: "max-h-0",
        transition_enter_end: "max-h-[1000px]",
        action: [
          "transition:transitioned->transition-group#startNext",
          "connection:connect->transition#enter",
        ],
      },
    ) do
      cards.find_each do |card|
        Components::Item(
          variant: :muted,
          size: :sm,
          class: "gap-y-2 hidden [&.hidden]:scale-95",
          data: {
            hidden_inline: true,
            transition_group_target: "item",
            controller: "transition",
            transition_enter: "transition-[opacity,scale] ease-in",
            transition_enter_start: "scale-95",
            action: [
              "transition-group:start->transition#enter",
              "transition:transitioned->transition-group#startNext",
            ],
          },
        ) do |item|
          item.media do
            Icon("huge/loyalty-card", class: "size-5")
          end
          item.content(class: "gap-0") do
            item.title do
              "you have an unlinked card for #{@world.name}"
            end
            item.description(class: "flex gap-1") do
              plain("card id:")
              span(class: "font-mono") { card.short_id }
            end
          end
          item.actions(class: "mx-auto") do
            form_with(model: [ :claim, card ], method: :post) do |form|
              submit_button_for(form, size: :sm) do |button|
                button.inline_start_icon("huge/link-01")
                span { "claim card" }
              end
            end
          end
        end
      end
    end if cards.any?
  end
end
