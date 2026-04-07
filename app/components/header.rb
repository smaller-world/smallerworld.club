# typed: true
# frozen_string_literal: true

class Components::Header < Components::Base
  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    site_name = Rails.configuration.x.site.name
    root_element(:header, class: "flex justify-center py-2") do
      Components::Button(
        element: :a,
        variant: :ghost,
        href: root_path,
        class: "gap-x-1.5",
      ) do
        image_tag(
          "logo.png",
          alt: [ site_name, "logo" ].compact.join(" "),
          class:  "size-5 dark:size-5.5",
          data: {
            icon: ("inline-start" if site_name),
          },
        )
        if site_name
          span(class: "font-heading font-semibold text-lg") do
            site_name
          end
        end
      end
    end
  end
end
