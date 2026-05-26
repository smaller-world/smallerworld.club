# typed: strict
# frozen_string_literal: true

class Views::WorldKeyGrants::New < Views::Base
  # == Initialization ==

  sig { params(world: World, key_color: T.nilable(Symbol)).void }
  def initialize(world:, key_color:)
    @world = world
    @key_color = key_color
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(page_title: "share world key") do |layout|
      layout.page_container(class: "max-w-lg space-y-4") do
        button_back_to(@world.name, @world)

        Components::Card(class: "overflow-visible") do |card|
          card.header(class: "text-center") do
            card.title(element: :h1, class: "text-xl") do
              "share a key to your world"
            end
            card.description(class: "text-balance") do
              "> hint: when you write posts, you can select which colors can see your post"
            end
          end
          card.content do
            turbo_frame_tag(:form) do
              Components::WorldKeyGrantForm(world: @world, key_color: @key_color)
            end
          end
        end
      end
    end
  end
end
