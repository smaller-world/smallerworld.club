# typed: strict
# frozen_string_literal: true

class Views::Posts::Index < Views::Base
  # == Initialization ==

  sig do
    params(
      world: World,
      posts: T::Enumerable[Post],
      pagy: T.nilable(Pagy),
      replied_post_ids: T.nilable(T::Set[String]),
      created_post_id: T.nilable(String),
    ).void
  end
  def initialize(
    world:,
    posts:,
    pagy:,
    replied_post_ids:,
    created_post_id:
  )
    @world = world
    @posts = posts
    @pagy = pagy
    @replied_post_ids = replied_post_ids
    @created_post_id = created_post_id
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    turbo_frame_tag(:posts) do
      div(class: "space-y-4") do
        if @posts.any?
          ul(id: "post_items", class: "space-y-4") do
            Components::WorldPostItems(
              posts: @posts,
              replied_post_ids: @replied_post_ids,
              created_post_id: @created_post_id,
            )
          end
        else
          Components::Empty() do |empty|
            empty.header(class: "gap-0") do
              empty.media(variant: :icon) do
                Icon("huge/message-edit-01")
              end
              empty.title do
                "no posts yet!"
              end
              # empty.description do
              #   button_link_to("need some inspo on what to write?")
              # end
            end
          end
        end
        if @pagy.nil? || @pagy.next
          div(class: "flex flex-col items-center") do
            Components::WorldNextPageControl(world: @world, pagy: @pagy)
          end
        end
      end

      turbo_stream_from(@world, :posts)
    end
  end
end
