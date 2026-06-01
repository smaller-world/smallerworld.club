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
        button_back_to(@world.name, @world) unless hotwire_native_app?

        Components::PostForm(post: @post)
      end
    end
  end
end
