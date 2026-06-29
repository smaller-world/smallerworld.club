# typed: strict
# frozen_string_literal: true

class Views::Worlds::New < Views::Base
  # == Initialization ==

  sig { params(world: World).void }
  def initialize(world:)
    super()
    @world = world
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "create your world") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to(:home, variant: :secondary)
        end

        Components::HintAlert(message: "your world is the place where your posts live!")
        Components::WorldForm(world: @world)
      end
    end
  end
end
