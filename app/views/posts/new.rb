# typed: strict
# frozen_string_literal: true

class Views::Posts::New < Views::Base
  # == Initialization ==

  sig { params(post: Post).void }
  def initialize(post:)
    @post = post
    @world = T.let(post.world!, World)
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "new post") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        button_back_to(@world.name, @world) unless hotwire_native_app?

        Components::HintAlert(
          message: "a good post is one that feels good to write!",
        )
        Components::PostForm(post: @post)
      end
    end
  end
end
