# typed: strict
# frozen_string_literal: true

class Views::Posts::New < Views::Base
  # == Initialization ==

  sig { params(post: Post, restore_draft: T::Boolean).void }
  def initialize(post:, restore_draft: false)
    super()
    @post = post
    @restore_draft = restore_draft
    @world = T.let(@post.world!, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "new post") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to(@world.name, @world, variant: :secondary)
        end

        Components::HintAlert(
          message: "a good post is one that feels good to write!",
        )
        Components::PostForm(post: @post, restore_draft: @restore_draft)
      end
    end
  end
end
