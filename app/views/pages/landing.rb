# typed: strict
# frozen_string_literal: true

class Views::Pages::Landing < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(title:) do
      main(class: "flex flex-col items-center gap-8 py-10 overflow-x-clip") do
        div(class: "flex flex-col items-center gap-4 mt-12 md:mt-20") do
          image_tag("app_on_homescreen-square.png", class: "size-24 rounded-xl")
          div(class: "flex flex-col items-center gap-1 text-center text-balance") do
            h1(class: "text-foreground font-semibold text-xl") do
              "hi. welcome to smaller world!"
            end
            p(class: "text-balance text-muted-foreground max-w-xs") do
              "smaller world is a place to share your feelings with friends."
            end
          end
        end

        button_link_to(
          "get the app!",
          install_path,
          variant: :default,
          size: :xl,
          icon: "huge/app-store",
          class: "mb-4 md:mb-8",
        )

        div(class: "w-full px-4 space-y-2") do
          p(class: "text-xs text-muted-foreground text-center text-balance max-w-xs mx-auto sm:max-w-none") do
            "see and share posts like these, alongside the people already in your life today."
          end
          app_screenshots
        end

        div(class: "flex flex-col gap-1 text-center") do
          link_to("see our terms and policies", policies_path, class: "link text-xs")
          link_to(
            "contact us",
            support_path,
            class: "link text-xs",
            data: { turbo_stream: true },
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(String)) }
  def title
    application = SmallerWorld.application
    "#{application.site_name}: #{application.site_tagline}"
  end

  sig { void }
  def app_screenshots
    images = [ "landing-post2.jpg", "landing-post3.jpg", "landing-post1.png" ]
    div(
      class: "glide max-w-xs mx-auto sm:max-w-2xl md:max-w-5xl md:cursor-default",
      data: {
        controller: "landing-carousel",
      },
    ) do
      div(
        class: "glide__track overflow-visible md:overflow-hidden md:pointer-events-none",
        data: {
          glide_el: "track",
        },
      ) do
        ul(class: "glide__slides") do
          images.each do |filename|
            li(class: "glide__slide") do
              image_tag(filename, class: "rounded-xl")
            end
          end
        end
      end
    end
  end
end
