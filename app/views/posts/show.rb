# typed: strict
# frozen_string_literal: true

class Views::Posts::Show < Views::Base
  # == Initialization ==

  sig { params(post: Post).void }
  def initialize(
    post:
  )
    super()
    @post = post
    @active_report = T.let(post.reports.not_dismissed.first, T.nilable(Report))
    @world = T.let(post.world!, World)
    @world_owner = T.let(@world.owner!, User)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: @world.name) do |app_layout|
      app_layout.with_navigation(class: "max-w-lg") do
        button_back_to(@world.name, @world, variant: :secondary)
      end

      app_layout.page_container(class: "max-w-lg") do
        div(class: "flex flex-col gap-6") do
          section(class: "flex flex-col items-center gap-2") do
            image_tag(
              @world.page_icon_variant,
              id: dom_id(@world, :page_icon),
              class: "world-icon size-32",
            )
            h1(class: "text-2xl text-center") do
              @world.name
            end
            if (blurb = @world.blurb)
              p(class: "whitespace-pre-wrap text-center text-muted-foreground text-sm") do
                auto_link(blurb, html: {
                  class: "underline underline-offset-4",
                  target: "_blank",
                  rel: "noopener noreferrer nofollow",
                }) do |text|
                  # Normalize URL (strip protocol)
                  Addressable::URI.parse(text).omit(:scheme).to_s.delete_prefix("//")
                end
              end
            end
          end
        end

        Components::PostCard(
          post: @post,
          active_report: @active_report,
          auto_collapse: false,
        )
      end
    end
  end
end
