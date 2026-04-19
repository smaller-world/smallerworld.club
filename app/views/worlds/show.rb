# typed: true
# frozen_string_literal: true

class Views::Worlds::Show < Views::Base
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
        div(class: "flex justify-between") do
          if current_user == @world.owner
            button_back_to_home
          else
            div
          end

          button_to(
            "edit",
            edit_world_path(@world),
            icon: "huge/pencil-edit-01",
            variant: :secondary,
          )
        end

        Components::Card() do |card|
          card.header(class: "flex flex-col items-center gap-y-2") do
            image_tag(@world.page_icon_variant, class: "size-24 rounded-full")
            card.title(element: :h1, class: "text-xl text-center") do
              @world.name
            end
          end
          card.content do
            "welcome to my lovely world..."
            # Components::WorldForm(world: @world)
          end
        end
      end
    end
  end
end
