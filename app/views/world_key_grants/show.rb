# typed: strict
# frozen_string_literal: true

class Views::WorldKeyGrants::Show < Views::Base
  # == Initialization ==

  sig { params(key_or_card: T.any(WorldKey, WorldCard)).void }
  def initialize(key_or_card:)
    @key_or_card = T.let(key_or_card, T.any(WorldKey, WorldCard))
    @world = T.let(@key_or_card.world!, World)
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "you got a key!") do |layout|
      layout.page_container(
        class: "flex-1 max-w-lg flex flex-col items-center justify-center gap-8",
      ) do
        span(class: "text-lg font-semibold") do
          "you've been given a #{label} to:"
        end
        div(class: "home-world-link") do
          div(class: "relative") do
            image_tag(@world.page_icon_variant, class: "home-world-icon")
            div(class: "absolute inset-0 flex items-center justify-center") do
              Icon("huge/key-02", class: "size-14 text-background")
            end
          end
          span(class: "home-world-label") do
            @world.name
          end
        end

        case @key_or_card
        when WorldKey
          Components::AcceptWorldKeyForm(key: @key_or_card)
        when WorldCard
          Components::WorldCardForm(card: @key_or_card)
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def label
    if @key_or_card.is_a?(WorldKey)
      "key"
    else
      "keycard"
    end
  end
end
