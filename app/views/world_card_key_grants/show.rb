# typed: strict
# frozen_string_literal: true

class Views::WorldCardKeyGrants::Show < Views::Base
  # == Initialization ==

  sig { params(card: WorldCard).void }
  def initialize(card:)
    @card = card
    @world = T.let(card.world!, World)
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "you have a world card!") do |layout|
      layout.page_container(
        class: "flex-1 max-w-lg flex flex-col items-center justify-center gap-8",
      ) do
        span(class: "text-lg font-semibold") do
          "you have an access card to:"
        end
        div(class: "world-icon-container") do
          div(class: "relative") do
            image_tag(@world.page_icon_variant, class: "world-icon")
            div(class: "absolute inset-0 flex items-center justify-center") do
              Icon("huge/loyalty-card", class: "size-14 text-white")
            end
          end
          span(class: "world-icon-label") do
            @world.name
          end
        end

        Components::AcceptWorldCardKeyGrantForm(card: @card)
      end
    end
  end
end
