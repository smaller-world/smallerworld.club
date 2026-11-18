# typed: strict
# frozen_string_literal: true

class Views::Places::Dock < Views::Base
  include Phlex::Rails::Helpers::AssetPath
  include Phlex::Rails::Helpers::FormWith

  # == Initialization ==

  sig { params(current_user: User).void }
  def initialize(current_user:)
    super()
    @current_user = current_user
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "the dock") do |app_layout|
      app_layout.with_navigation(class: "max-w-lg") do
        button_back_to(:home, variant: :secondary)
      end

      # app_layout.with_alert do
      #   Components::Alert(variant: :destructive) do |alert|
      #     Icon("huge/wrench-01")
      #     alert.description do
      #       "this feature is under active development..."
      #     end
      #   end
      # end

      app_layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        div(class: "flex flex-col gap-3") do
          video(
            muted: true,
            loop: true,
            playsinline: true,
            poster: asset_path("places/dock_bg_poster.webp"),
            class: "place-background w-full max-w-sm h-auto hidden",
            data: {
              hidden_inline: true,
              controller: "autoplay transition",
              action: [
                "playing->transition#enter",
                "autoplay:denied->transition#enter",
                "pageshow@window->autoplay#resume",
                "page-visibility:invisible@document->autoplay#pause",
                "page-visibility:visible@document->autoplay#resume",
              ],
              transition_enter: "transition-opacity duration-[1400ms] ease-in-out",
              transition_enter_start: "opacity-0",
            },
            aria: {
              hidden: "true",
            },
          ) do
            source(src: asset_path("places/dock_bg.mov"), type: "video/quicktime")
            source(src: asset_path("places/dock_bg.webm"), type: "video/webm")
          end
          div(class: "text-center font-heading text-xs text-muted-foreground/80 italic") do
            plain("this is a private place to reflect on your day. it's a work in progress...")
            whitespace
            form_with(url: contact_request_path(purpose: "feedback"), class: "inline") do |form|
              form.button(class: "link underline") do
                "give feedback!"
              end
            end
          end
        end

        turbo_frame_tag(
          "reflections",
          target: "_top",
          data: {
            turbo_permanent: (true if hotwire_native_app?),
          },
        ) do
          form_with(
            url: reflections_path,
            method: :get,
            data: {
              turbo_frame: "reflections",
              controller: "submit",
            },
          ) do
            input(
              type: :hidden,
              name: "time_zone_name",
              data: {
                controller: "current-time-zone-input",
                action: "current-time-zone-input:set->submit#request",
              },
            )
          end
          Components::ItemGroup() do
            3.times do
              Components::ReflectionItemSkeleton()
            end
          end
        end
      end
    end
  end
end
