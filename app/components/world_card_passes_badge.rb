# typed: strict
# frozen_string_literal: true

class Components::WorldCardPassesBadge < Components::Base
  sig { override.void }
  def view_template
    root_element(
      :div,
      class: "flex flex-col gap-2 items-center",
      data: {
        controller: "transition-group",
      },
    ) do
      Components::Badge(
        variant: :outline,
        size: :sm,
        class: "hidden",
        data: {
          controller: "world-card-passes-badge passes-bridge transition",
          transition_group_target: "item",
          transition_enter: "transition-all duration-200 ease-in",
          transition_enter_start: "opacity-0 scale-95",
          action: [
            "passes-bridge:received->world-card-passes-badge#setLabel",
            "world-card-passes-badge:label-set->transition#enter",
            "transition:transitioned->transition-group#startNext",
          ],
        },
      ) do |badge|
        badge.inline_start_icon("huge/cards-02")
        span(data: { world_card_passes_badge_target: "label" })
      end

      p(
        class: "text-xs text-muted-foreground text-center",
        data: {
          controller: "transition",
          transition_enter: "transition-opacity ease-in",
          transition_enter_start: "opacity-0",
        },
      ) do
        "sign in to use your world cards"
      end
    end
  end
end
