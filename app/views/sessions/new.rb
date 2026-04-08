# typed: true
# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(
      title: "sign in to smaller world",
      body_class: "bg-muted",
    ) do |layout|
      layout.with_head do
        link(
          rel: "stylesheet",
          href: "https://fonts.googleapis.com/css2?family=Roboto:wght@500&display=swap",
        )
      end
      main(class: "flex-1 flex flex-col justify-center pb-20") do
        layout.page_container(
          class: "flex flex-col items-center justify-center",
        ) do
          render_card
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def render_card
    Components::Card(class: "w-full max-w-xs") do |card|
      card.header(class: "flex flex-col items-center gap-y-3") do
        image_tag("logo.png", class: "size-10")
        card.title(class: "text-lg text-center") do
          if (site_name = Rails.configuration.x.site.name)
            plain("sign in to ")
            span(class: "font-semibold") { site_name }
          else
            plain("sign in")
          end
        end
      end
      card.content(class: "flex flex-col items-stretch gap-y-3") do
        Components::SignInWithAppleButton()
        Components::SignInWithGoogleButton()
      end
    end
  end
end
