# typed: strict
# frozen_string_literal: true

class Views::Worlds::Edit < Views::Base
  # == Initialization ==

  sig { params(world: World).void }
  def initialize(world:)
    super()
    @world = world
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "edit world") do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        button_back_to("world", @world, variant: :secondary)
      end

      app_layout.page_container(class: "max-w-md") do
        div(class: "flex flex-col gap-0.5") do
          Components::WorldForm(world: @world)
          Components::ConfirmDeleteButton(
            url: @world,
            variant: :link,
            class: "self-center text-muted-foreground",
          ) do
            "delete world"
          end
        end
      end
    end
  end
end
