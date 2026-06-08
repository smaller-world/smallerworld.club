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
    Components::AppLayout(page_title: "share a key to your world") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        button_back_to(@world.name, @world) unless hotwire_native_app?

        Components::HintAlert(
          message: "choose wisely! your friends will be grouped by their key color.",
        )
        turbo_frame_tag(:form) do
          Components::WorldKeyGrantForm(world: @world, key_color: @key_color)
        end
      end
    end
  end
end
