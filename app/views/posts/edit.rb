# typed: true
# frozen_string_literal: true

class Views::Posts::Edit < Views::Base
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
    Components::Layout() do |layout|
      layout.page_container(class: "max-w-lg space-y-4") do
        button_back_to(@world.name, @world)

        Components::Card(class: "overflow-visible") do |card|
          card.header(class: "text-center") do
            card.title(element: :h1, class: "text-xl") do
              "edit post"
            end
            card.description do
              "> hint: a good post is one that feels good to write!"
            end
          end
          card.content do
            Components::PostForm(post: @post)
          end
        end
      end
    end
  end
end
