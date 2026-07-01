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
    Components::AppLayout(page_title: "edit world") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to("world", @world, variant: :secondary)
        end

        div(class: "flex flex-col gap-0.5") do
          Components::WorldForm(world: @world)
          Components::DropdownMenu() do |menu|
            menu.with_trigger_button(
              variant: :link,
              size: :sm,
              class: "text-muted-foreground",
            ) do
              "delete world"
            end
            menu.with_content(anchor: :bottom, class: "min-w-auto") do |menu_content|
              menu_content.label(class: "pt-1.5 pb-0.5 text-center") do
                "are you sure?"
              end
              form_with(url: @world, method: :delete) do
                menu_content.button_item(type: :submit, variant: :destructive) do
                  Icon("huge/delete-01")
                  span { "really delete" }
                end
              end
            end
          end
        end
      end
    end
  end
end
