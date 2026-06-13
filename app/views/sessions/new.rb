# typed: strict
# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  include Phlex::Rails::Helpers::Pluralize

  # == Initialization ==

  sig do
    params(
      verification_request: PhoneNumberVerificationRequest,
      unclaimed_world_cards: T.nilable(WorldCard::PrivateRelation),
    ).void
  end
  def initialize(verification_request:, unclaimed_world_cards:)
    @verification_request = verification_request
    @unclaimed_world_cards = unclaimed_world_cards
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      title: ("sign in to smaller world" unless hotwire_native_app?),
      body_class: "bg-muted [&_.flash]:bg-background",
      disable_cache: true,
    ) do |layout|
      layout.with_head do
        # JS for Cloudflare Turnstile
        link(rel: "preconnect", href: "https://challenges.cloudflare.com")
        script(
          src: "https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit&onload=onTurnstileLoad",
          async: true,
          defer: true,
        )
      end

      main(class: "flex-1 flex flex-col items-center justify-center") do
        layout.page_container(class: "flex flex-col items-center justify-center gap-6") do
          login_card

          if hotwire_native_app?
            turbo_frame_tag(:world_cards, class: "w-full max-w-72 empty:hidden") do
              if (cards = @unclaimed_world_cards)
                world_cards(cards)
              else
                Components::DevicePassesForm(url: new_session_path)
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
  def login_card
    Components::Card(class: "w-full max-w-90") do |card|
      card.header(class: "flex flex-col items-center gap-y-3") do
        image_tag("logo.png", class: "size-10")
        card.title(class: "text-lg text-center") do
          plain("sign in to ")
          span(class: "font-semibold") do
            Smallerworld.application.site_name
          end
        end
      end
      card.content do
        Components::PhoneNumberVerificationRequestForm(
          verification_request: @verification_request,
        )
      end
    end
  end

  sig { params(cards: WorldCard::PrivateRelation).void }
  def world_cards(cards)
    return if cards.empty?

    div(
      class: class_names("flex flex-col gap-3 overflow-hidden", "hidden"),
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
      Components::Badge(
        variant: :secondary,
        size: :sm,
        class: [
          "flex self-center bg-background",
          "hidden [&.hidden]:scale-95",
        ],
        data: {
          hidden_inline: true,
          transition_group_target: "item",
          controller: "transition",
          transition_enter: "transition-[opacity,scale] ease-in duration-200",
          transition_enter_start: "scale-95",
          action: [
            "transition-group:start->transition#enter",
            "transition:transitioned->transition-group#startNext",
          ],
        },
      ) do |badge|
        badge.inline_start_icon("huge/loyalty-card")
        span { "#{pluralize(cards.count, "unlinked world card")} found" }
      end

      Components::ItemGroup() do
        cards.find_each do |card|
          world = card.world!
          Components::Item(
            variant: :outline,
            size: :xs,
            class: "hidden [&.hidden]:scale-95",
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
              image_tag(
                world.page_icon_variant,
                class: "world-icon rounded-world-icon",
                data: { size: "xs" },
              )
            end
            item.content do
              item.title do
                world.name
              end
              if (blurb = world.blurb)
                item.description(class: "leading-xs line-clamp-1") do
                  blurb
                end
              end
            end
          end
        end
      end

      p(
        class: "text-center text-xs text-muted-foreground text-balance hidden",
        data: {
          hidden_inline: true,
          transition_group_target: "item",
          controller: "transition",
          transition_enter: "transition-all duration-600 delay-200 ease-in",
          transition_enter_start: "opacity-0",
          action: "transition-group:start->transition#enter",
        },
      ) do
        "these cards will be linked to your account when you sign in"
      end
    end
  end
end
