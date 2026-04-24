# typed: true
# frozen_string_literal: true

class Components::PostCard < Components::Base
  # == Initialization ==

  sig { params(post: Post, attributes: T.untyped).void }
  def initialize(post:, **attributes)
    @post = post
    @author = T.let(post.author!, User)
    @world = T.let(post.world!, World)
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    attributes = mix({ class: "gap-2" }, @attributes)
    Components::Card(**attributes) do |card|
      card.header do
        card.description(class: "text-xs") do
          local_time(@post.created_at, class: "lowercase")
        end
        if (title = @post.title)
          card.title(class: "text-xl font-semibold font-heading") do
            title
          end
        end
      end
      card.content do
        p(class: "whitespace-pre-line") do
          @post.body.to_s
        end
      end
    end
  end
end
