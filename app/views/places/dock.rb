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

      app_layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        video(
          autoplay: true,
          muted: true,
          loop: true,
          playsinline: true,
          data: { controller: "autoplay" },
          aria: { hidden: "true" },
          class: "place-background w-full max-w-sm h-auto"
        ) do
          source(src: asset_path("places/dock-background.mov"), type: "video/quicktime")
          source(src: asset_path("places/dock-background.webm"), type: "video/webm")
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
