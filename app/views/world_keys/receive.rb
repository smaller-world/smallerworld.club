# typed: true
# frozen_string_literal: true

class Views::WorldKeys::Receive < Views::Base
  # == Initialization ==

  sig { params(world_key: WorldKey).void }
  def initialize(world_key:)
    @world_key = world_key
    @world = T.let(world_key.world!, World)
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(page_title: "you got a key!") do |layout|
      layout.page_container(class: "max-w-lg space-y-4") do
        Components::Card(class: "overflow-visible") do |card|
          card.header(class: "text-center") do
            card.title(element: :h1, class: "text-xl") do
              plain("you got a key to")
              whitespace
              span(class: "font-semibold") { @world.name }
              plain("!")
            end
          end
          card.content do
            Components::AcceptWorldKeyForm(world_key: @world_key)
          end
        end
      end
    end
  end
end
