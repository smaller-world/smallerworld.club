# typed: strict
# frozen_string_literal: true

class Views::WorldKeyGrants::New < Views::Base
  # == Initialization ==

  sig { params(grant: WorldKeyGrant).void }
  def initialize(grant:)
    super()
    @grant = grant
    @world = T.let(grant.world, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      page_title: "share a key to your world",
      disable_cache: true,
    ) do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        button_back_to("your friends", [ @world, :keys ], variant: :secondary)
      end

      app_layout.page_container(class: "max-w-md") do
        div(class: "relative self-center") do
          image_tag(
            @world.page_icon_variant,
            class: "world-icon",
            data: {
              world_icon_size: "sm",
            },
          )
          div(class: "absolute inset-0 flex items-center justify-center") do
            Icon("huge/key-01", class: "size-10 text-white")
          end
        end

        Components::WorldKeyGrantForm(grant: @grant)
      end
    end
  end
end
