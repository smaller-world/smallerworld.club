# typed: strict
# frozen_string_literal: true

class Views::Pages::Landing < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(title:) do |app_layout|
      main(class: "flex-1 flex flex-col justify-center") do
        app_layout.page_container(class: "flex flex-col items-center gap-6") do
          div(class: "flex flex-col items-center gap-4") do
            image_tag(
              "logo.png",
              alt: [ Smallerworld.application.site_name, "logo" ].join(" "),
              class: "size-10",
            )

            div(class: "flex flex-col items-center gap-1 text-center text-balance") do
              h1(class: "text-foreground font-semibold text-lg") do
                "hi. welcome to smaller world!"
              end
              p(class: "text-balance text-muted-foreground max-w-xs") do
                "smaller world is a place where you can share your inner world with " \
                  "your friends :)"
              end
            end
          end

          button_link_to(
            "get the app!",
            installation_instructions_path,
            variant: :default,
            size: :xl,
            icon: "huge/app-store",
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def title
    site = Rails.configuration.x.site
    [ site.tagline, site.name ].compact.join(" – ").presence
  end
end
