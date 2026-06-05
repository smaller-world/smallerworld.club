# typed: strict
# frozen_string_literal: true

class Views::Pages::Landing < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(title:) do |layout|
      main(class: "flex-1 flex flex-col justify-center") do
        layout.page_container(class: "flex flex-col items-center gap-6") do
          div(class: "flex flex-col items-center gap-1 text-center text-balance") do
            h1(class: "text-foreground font-medium text-lg") do
              "hi. welcome to smaller world!"
            end
            p(class: "text-balance text-muted-foreground max-w-xs") do
              "smaller world is a place where you can share your inner world with " \
                "close friends :)"
            end
          end
          button_link_to(
            "install smaller world on ios",
            testflight_path,
            variant: :default,
            size: :lg,
            icon: "huge/apple",
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
    [ site.name, site.tagline ].compact.join(" | ").presence
  end
end
