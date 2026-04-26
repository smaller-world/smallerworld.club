# typed: true
# frozen_string_literal: true

class Components::Header < Components::Base
  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    site_name = Rails.configuration.x.site.name
    root_element(:header, class: "flex justify-center py-2") do
      Components::DropdownMenu(anchor: :bottom) do |menu|
        menu.trigger do
          Components::Button(
            **({ element: :a, href: root_path } unless authenticated?),
            variant: :ghost,
            class: "gap-x-1.5",
          ) do
            image_tag(
              "logo.png",
              alt: [ site_name, "logo" ].compact.join(" "),
              class: "size-5 dark:size-5.5",
              data: {
                icon: ("inline-start" if site_name),
              },
            )

            span(class: "font-heading font-semibold text-lg") do
              site_name || "[unnamed site]"
            end
          end
        end
        if authenticated?
          menu.content do
            menu.group do
              menu.label { "[some group]" }
              menu.link_item(href: home_path) do
                Icon("huge/home-01", class: "size-4")
                span { "Home" }
              end
              menu.button_item { "[some item]" }
            end
            menu.separator
            form_with(url: session_path, method: :delete) do
              menu.button_item(type: :submit, variant: :destructive) do
                Icon("huge/logout-01", class: "size-4")
                span { "sign out" }
              end
            end
          end
        end
      end
    end
  end
end
