# typed: strict
# frozen_string_literal: true

class Views::Posts::Edit < Views::Base
  # == Initialization ==

  sig { params(post: Post).void }
  def initialize(post:)
    super()
    @post = post
    @world = T.let(post.world!, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "edit post") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to(@world.name, @world, variant: :secondary)
        end

        div(class: "flex flex-col gap-0.5") do
          Components::PostForm(post: @post)
          Components::ConfirmDeleteButton(
            target: @post,
            variant: :link,
            class: "self-center text-muted-foreground",
          ) do
            "delete post"
          end
        end
      end
    end
  end
end
