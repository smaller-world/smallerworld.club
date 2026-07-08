# typed: strict
# frozen_string_literal: true

class Views::WorldCards::Show < Views::Base
  # # == Initialization ==

  # sig { params(card: WorldCard).void }
  # def initialize(card:)
  #   super()
  #   @card = card
  #   @world = T.let(@card.world!, World)
  # end

  # # == View ==

  # sig { override.void }
  # def view_template
  #   Components::AppLayout(page_title: "you got an access card!") do |layout|
  #     layout.page_container(
  #       class: "flex-1 max-w-lg flex flex-col items-center justify-center gap-8",
  #     ) do
  #       span(class: "text-lg font-semibold") do
  #         "you've been given an access card to:"
  #       end
  #       div(class: "world-icon-container") do
  #         div(class: "relative") do
  #           image_tag(@world.page_icon_variant, class: "world-icon")
  #           div(class: "absolute inset-0 flex items-center justify-center") do
  #             Icon("huge/key-02", class: "size-14 text-background")
  #           end
  #         end
  #         span(class: "world-icon-label") do
  #           @world.name
  #         end
  #       end

  #       div(
  #         class: "flex flex-col items-center gap-2.5",
  #         data: {
  #           controller: "transition-group",
  #         },
  #       ) do
  #         Components::Button(
  #           element: :a,
  #           href: url_for([ :download, @card ]),
  #           download: true,
  #           variant: :default,
  #           size: :lg,
  #           class: "data-disabled:bg-secondary data-disabled:text-secondary-foreground",
  #           data: {
  #             controller: "disabled",
  #             disabled_message_value: "your card is downloading...",
  #             action: "disabled#disable transition-group#start",
  #           },
  #         ) do |button|
  #           button.inline_start_icon("huge/loyalty-card")
  #           span(data: { disabled_target: "message" }) do
  #             "add card to wallet"
  #           end
  #         end

  #         span(
  #           class: "text-sm text-muted-foreground text-center text-balance max-w-xs",
  #           data: {
  #             transition_group_target: "item",
  #             controller: "transition",
  #             transition_leave: "transition-opacity delay-2000",
  #             transition_leave_end: "opacity-0",
  #             action: [
  #               "transition-group:start->transition#leave",
  #               "transition:transitioned->transition-group#startNext",
  #             ],
  #           },
  #         ) do
  #           plain("once you've ")
  #           link_to(
  #             "downloaded the app",
  #             appstore_listing_url,
  #             target: "_blank",
  #             rel: "noopener noreferrer",
  #             class: "text-primary",
  #           )
  #           plain(", this card will give you access to #{@world.name}")
  #         end

  #         div(
  #           class: [ "flex flex-col items-center gap-2", "hidden" ],
  #           data: {
  #             transition_group_target: "item",
  #             controller: "transition",
  #             transition_enter: "transition-[opacity,scale] duration-200 delay-100",
  #             transition_enter_start: "opacity-0 scale-95",
  #             action: "transition-group:start->transition#enter",
  #           },
  #         ) do
  #           span(class: "text-sm text-muted-foreground") do
  #             "next:"
  #           end
  #           button_link_to(
  #             "open the smaller world app!",
  #             home_path(require_app: 1),
  #             variant: :default,
  #             size: :lg,
  #             icon: "huge/app-store",
  #           )
  #         end
  #       end
  #     end
  #   end
  # end
end
