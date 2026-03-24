# typed: true
# frozen_string_literal: true

class Components::Header < Components::Base
  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    site_name = Rails.configuration.x.site_name
    root_element(:header, class: "flex justify-center border-b border-border") do
      div(class: "w-full max-w-2xl py-2 px-4 flex justify-between items-center") do
        Components::Button(
          element: :a,
          variant: :ghost,
          href: root_path,
          class: "gap-2",
        ) do
          image_tag(
            "icon.png",
            alt: [ site_name, "logo" ].compact.join(" "),
            class: [
              "size-5 dark:size-5.5",
              "dark:p-[2px] dark:rounded-full dark:bg-primary-foreground",
            ],
            data: {
              icon: ("inline-start" if site_name),
            },
          )
          if site_name
            span(class: "font-bold text-lg") do
              site_name
            end
          end
        end
        render_navigation
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def render_navigation
    config = Rails.configuration.x
    instagram_url = config.instagram_url
    tiktok_url = config.tiktok_url
    luma_url = config.luma_url

    ul(class: "header_navigation") do
      if instagram_url || tiktok_url
        li do
          ul(class:  "flex items-center gap-x-1") do
            li(data: {
              controller: "tooltip",
              tooltip_content_value: "follow us on instagram",
            }) do
              a(href: instagram_url, target: "_blank") do
                Icon(
                  "huge/instagram",
                  class: "size-5.5 text-secondary dark:text-secondary-foreground",
                )
              end
            end
            li(data: {
              controller: "tooltip",
              tooltip_content_value: "follow us on tiktok",
            }) do
              a(href: tiktok_url, target: "_blank") do
                Icon(
                  "huge/tiktok",
                  class: "size-5.5 text-secondary dark:text-secondary-foreground",
                )
              end
            end
          end
        end
      end

      if (instagram_url || tiktok_url) && luma_url
        Components::Separator(orientation: :vertical)
      end

      if luma_url
        li do
          Components::Button(
            element: :a,
            href: luma_url,
            target: "_blank",
            variant: :outline,
            size: :sm,
            class: [
              "bg-accent-foreground border-accent text-accent",
              "dark:bg-accent/10",
            ],
            data: {
              controller: "tooltip",
              tooltip_content_value: "view upcoming events",
            },
          ) do
            Icon(
              "huge/calendar-03",
              class: "size-5.5",
              data: { icon: "inline-start" },
            )
            span(class: "text-sm font-medium") { "events" }
          end
        end
      end
    end
  end
end
