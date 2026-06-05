# typed: strict
# frozen_string_literal: true

class Views::WorldCards::Unlinked < Views::Base
  include Phlex::Rails::Helpers::Pluralize

  # == Initialization ==

  sig { params(world_cards: WorldCard::PrivateRelation).void }
  def initialize(world_cards:)
    @world_cards = world_cards
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    turbo_frame_tag(:unlinked_world_cards) do
      next if @world_cards.blank?

      div(
        class: class_names("flex flex-col gap-3 overflow-hidden", "hidden"),
        data: {
          controller: "transition-group transition connection",
          transition_group_target: "item",
          transition_enter: "transition-[max-height] duration-400 ease-in",
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
              "click->transition#toggle",
            ],
          },
        ) do |badge|
          badge.inline_start_icon("huge/cards-02")
          span { "#{pluralize(@world_cards.count, "unlinked world card")} found" }
        end

        Components::ItemGroup() do
          @world_cards.each do |card|
            world = card.world!
            Components::Item(
              variant: :outline,
              size: :xs,
              class: "rounded-xl hidden [&.hidden]:scale-95",
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
end
