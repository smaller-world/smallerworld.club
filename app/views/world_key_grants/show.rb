# typed: strict
# frozen_string_literal: true

class Views::WorldKeyGrants::Show < Views::Base
  # == Initialization ==

  sig { params(key: WorldKey).void }
  def initialize(key:)
    @key = key
    @world = T.let(key.world!, World)
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
          "you've been given a key to:"
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

        Components::AcceptWorldKeyForm(key: @key)
      end
    end
  end
end
