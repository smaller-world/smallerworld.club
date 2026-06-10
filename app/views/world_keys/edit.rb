# typed: strict
# frozen_string_literal: true

class Views::WorldKeys::Edit < Views::Base
  # == Initialization ==

  sig { params(world: World).void }
  def initialize(world:)
    @world = world
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "customize world keys") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        button_back_to("your friends", [ @world, :keys ]) unless hotwire_native_app?

        Components::WorldKeysForm(world: @world)
      end
    end
  end
end
