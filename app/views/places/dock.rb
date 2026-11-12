# typed: strict
# frozen_string_literal: true

class Views::Places::Dock < Views::Base
  include Phlex::Rails::Helpers::AssetPath

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "the dock") do |app_layout|
      app_layout.with_navigation(class: "max-w-lg") do
        button_back_to(:home, variant: :secondary)
      end

      app_layout.with_alert do
        Components::Alert(variant: :destructive) do |alert|
          Icon("huge/wrench-01")
          alert.description do
            "this feature is under active development..."
          end
        end
      end

      app_layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        video(
          poster: asset_path("places/dock_background_poster.webp"),
          muted: true,
          loop: true,
          playsinline: true,
          class: "place-background w-full max-w-sm h-auto hidden",
          data: {
            hidden_inline: "",
            controller: "autoplay transition",
            action: [
              "playing->transition#enter",
              "autoplay:denied->transition#enter",
              "pageshow@window->autoplay#resume",
              "page-visibility:invisible@document->autoplay#pause",
              "page-visibility:visible@document->autoplay#resume",
            ],
            transition_enter: "transition-opacity duration-[1400ms] ease-in-ou",
            transition_enter_start: "opacity-0",
          },
          aria: {
            hidden: "true"
          },
        ) do
          source(src: asset_path("places/dock_background.mov"), type: "video/quicktime")
          source(src: asset_path("places/dock_background.webm"), type: "video/webm")
        end

        section(class: "flex flex-col gap-2") do
          h1(class: "text-xl") do
            "welcome to the dock"
          end

          Components::LexxyEditor(placeholder: "what's on your mind today?")
        end
      end
    end
  end
end
