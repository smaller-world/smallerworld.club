# typed: strict
# frozen_string_literal: true

class Views::WorldKeyGrants::New < Views::Base
  # == Initialization ==

  sig { params(world: World, granted_post_types: T::Array[PostType]).void }
  def initialize(world:, granted_post_types:)
    @world = world
    @granted_post_types = granted_post_types
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "share a key to your world") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to("your friends", [ @world, :keys ], variant: :secondary)
        end

        Components::WorldKeyGrantForm(
          world: @world,
          granted_post_types: @granted_post_types,
        )
      end
    end
  end
end
