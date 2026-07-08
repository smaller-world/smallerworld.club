# typed: strict
# frozen_string_literal: true

class Views::WorldKeys::Show < Views::Base
  # == Initialization ==

  sig { params(world_key: WorldKey).void }
  def initialize(world_key:)
    super()
    @world_key = world_key
    @world = T.let(world_key.world!, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "world settings") do |app_layout|
      app_layout.page_container(class: "max-w-lg space-y-6") do
        button_back_to("world", @world, variant: :secondary) unless hotwire_native_app?

        Components::Card(
          size: :sm,
          class: "hidden with-notification-token-bridge:revert-display-layer",
        ) do |card|
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
            Components::Popover() do |popover|
              popover.with_trigger_button(variant: :outline) do |button|
                button.inline_start_icon("huge/logout-02")
                span { "leave #{@world.name}" }
              end
              popover.with_content(class: "max-w-60") do |popover_content|
                popover_content.header(class: "text-center") do |popover_header|
                  popover_header.title { "are you sure?" }
                  popover_header.description do
                    "this action is permanent and cannot be undone"
                  end
                end
                Components::Form(@world_key, method: :delete) do |form|
                  form.submit(variant: :destructive, class: "w-full") do |button|
                    button.inline_start_icon("huge/heartbreak")
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
