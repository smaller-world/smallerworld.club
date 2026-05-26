# typed: strict
# frozen_string_literal: true

class Components::Header < Components::Base
  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    logo_button_options = { variant: :ghost, class: "gap-x-1.5" }

    root_element(:header, class: "flex justify-center py-2") do
      if authenticated?
        Components::DropdownMenu() do |menu|
          menu.with_trigger_button(**logo_button_options) do
            logo_button_content
          end

          menu.with_content(anchor: :bottom, class: "w-56") do |content|
            content.group do
              # content.label { "[some group]" }
              content.link_item_to(:home) do
                Icon("huge/home-01", class: "size-4")
                span { "home" }
              end
              # content.button_item { "[some item]" }
            end
            content.separator
            form_with(url: session_path, method: :delete) do
              content.button_item(type: :submit, variant: :destructive) do
                Icon("huge/logout-01", class: "size-4")
                span { "sign out" }
              end
            end
          end
        end
      else
        button_link_to(root_path, **logo_button_options) do
          logo_button_content
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def logo_button_content
    site_name = Rails.configuration.x.site.name

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
