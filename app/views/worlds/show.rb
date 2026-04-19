# typed: true
# frozen_string_literal: true

class Views::Worlds::Show < Views::Base
  # == Configuration ==

  sig { params(world: World).void }
  def initialize(world:)
    @world = world
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout() do |layout|
      layout.page_container(class: "max-w-lg space-y-4") do
        if current_user == @world.owner
          Components::BackToHomeButton()
        end

        Components::Card() do |card|
          card.header(class: "flex flex-col items-center gap-y-2") do
            image_tag(@world.page_icon_variant, class: "size-24 rounded-full")
            card.title(element: :h1, class: "text-xl text-center") do
              @world.name
            end
          end
          card.content do
            "ffft"
            # Components::WorldForm(world: @world)
          end
        end
      end
    end
  end
end
