# typed: strict
# frozen_string_literal: true

class Views::WorldKeyGrants::Show < Views::Base
  # == Initialization ==

  sig { params(world: World, grant: String).void }
  def initialize(world:, grant:)
    @world = world
    @grant = grant
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
        div(class: "world-icon-container") do
          div(class: "relative") do
            image_tag(@world.page_icon_variant, class: "world-icon")
            div(class: "absolute inset-0 flex items-center justify-center") do
              Icon("huge/key-02", class: "size-14 text-white")
            end
          end
          span(class: "world-icon-label") do
            @world.name
          end
        end

        Components::AcceptWorldKeyGrantForm(world: @world, grant: @grant)
      end
    end
  end
end
