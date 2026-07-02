# typed: strict
# frozen_string_literal: true

class Views::WorldKeyGrants::New < Views::Base
  # == Initialization ==

  sig { params(world: World, granted_post_types: T::Array[PostType]).void }
  def initialize(world:, granted_post_types:)
    super()
    @world = world
    @granted_post_types = granted_post_types
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "share a key to your world") do |layout|
      layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        unless hotwire_native_app?
          button_back_to(
            "your friends",
            [ @world, :keys ],
            variant: :secondary,
            class: "self-start",
          )
        end

        div(class: "relative self-center") do
          image_tag(
            @world.page_icon_variant,
            class: "world-icon",
            data: {
              world_icon_size: "sm",
            },
          )
          div(class: "absolute inset-0 flex items-center justify-center") do
            Icon("huge/key-01", class: "size-8 text-white")
          end
        end

        turbo_frame_tag(:world_key_grant_form) do
          Components::WorldKeyGrantForm(
            world: @world,
            granted_post_types: @granted_post_types,
          )
        end
      end
    end
  end
end
