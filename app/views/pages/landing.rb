# typed: true
# frozen_string_literal: true

class Views::Pages::Landing < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(site_title:) do |layout|
      main(class: "flex-1 flex flex-col justify-center pb-20") do
        layout.page_container(class: "flex flex-col items-center gap-y-6") do
          div(class: "flex flex-col items-center gap-y-2") do
            image_tag("logo.png", class: "size-14")
            h1(class: "text-2xl font-bold") do
              "welcome to smaller world!!"
            end
          end
          div(class: "font-cursive text-xl text-center text-muted-foreground") do
            p do
              "i'm rebuilding smaller world from scratch"
            end
            p do
              "cuz i'm terrible at prioritizing my time"
            end
            p do
              "and also i operate entirely on"
            end
            p do
              "✨ creative inspiration ✨"
            end
          end
          Components::Button(
            element: :a,
            href: new_session_path,
            size: :lg,
          ) do
            Icon(
              "huge/door-01",
              class: "size-6",
              data: { icon: "inline-start" },
            )
            span do
              "enter if u dare"
            end
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def site_title
    site = Rails.configuration.x.site
    [ site.name, site.tagline ].compact.join(" | ").presence
  end
end
