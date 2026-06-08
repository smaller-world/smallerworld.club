# typed: strict
# frozen_string_literal: true

class Views::WorldSettings::Show < Views::Base
  # == Initialization ==

  sig { params(world: World).void }
  def initialize(world:)
    @world = world
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "world settings") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        button_back_to("world", @world) unless hotwire_native_app?

        Components::Card(size: :sm) do |card|
          card.header do
            card.title(class: "text-center") { "notification settings" }
          end
          card.content(class: "text-center text-muted-foreground") do
            "will be available in a future update ;)"
          end
        end

        Components::Card(size: :sm) do |card|
          card.header do
            card.title(class: "text-center") { "break-up zone" }
          end
          card.footer(class: "flex flex-col items-stretch") do
            Components::DropdownMenu() do |menu|
              menu.with_trigger_button(variant: :outline) do |button|
                button.inline_start_icon("huge/logout-02")
                span { "leave #{@world.name}" }
              end
              menu.with_content(anchor: :bottom) do |content|
                form_with(url: [ :leave, @world ]) do
                  content.button_item(type: :submit, variant: :destructive) do
                    Icon("huge/heartbreak")
                    span { "really leave" }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
