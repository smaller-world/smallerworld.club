# typed: strict
# frozen_string_literal: true

class Views::Worlds::Edit < Views::Base
  # == Initialization ==

  sig { params(world: World).void }
  def initialize(world:)
    @world = world
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "edit world") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to("world", @world, variant: :secondary)
        end

        Components::WorldForm(world: @world)
      end
    end
  end
end
