# typed: true
# frozen_string_literal: true

class Views::Worlds::New < Views::Base
  include Phlex::Rails::Helpers::ButtonTo

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
        Components::BackToHomeButton()

        Components::Card() do |card|
          card.header(class: "text-center") do
            card.title(element: :h1, class: "text-xl") do
              "create your world"
            end
            card.description do
              "> hint: your world is the place where your posts live!"
            end
          end
          card.content do
            Components::WorldForm(world: @world)
          end
        end
      end
    end
  end
end
