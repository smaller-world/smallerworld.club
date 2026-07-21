# typed: strict
# frozen_string_literal: true

class Views::Posts::Index < Views::Base
  # == Initialization ==

  sig do
    params(
      current_user: User,
      world: World,
      post_type: T.nilable(PostType),
      posts: T::Enumerable[Post],
      pagy: Pagy,
      replied_post_ids: T.nilable(T::Set[String]),
    ).void
  end
  def initialize(
    current_user:,
    world:,
    post_type:,
    posts:,
    pagy:,
    replied_post_ids:
  )
    super()
    @current_user = current_user
    @world = world
    @post_type = post_type
    @posts = posts
    @pagy = pagy
    @replied_post_ids = replied_post_ids
  end

  # == View ==

  sig { override.void }
  def view_template
    turbo_frame_tag(@world, :posts) do
      div(class: "space-y-4") do
        ul(id: "post_items", class: "space-y-4 empty:hidden") do
          Components::WorldPostItems(
            current_user: @current_user,
            posts: @posts,
            replied_post_ids: @replied_post_ids,
          )
        end
        Components::Empty(class: "hidden [ul:empty+&]:revert-display-layer") do |empty|
          empty.header(class: "gap-0") do
            empty.media(variant: :icon) do
              Icon("huge/dashed-line-02", class: "text-muted-foreground")
            end
            empty.title(class: "text-muted-foreground") do
              "you haven't written anything yet..."
            end
            # empty.description do
            #   button_link_to("need some inspo on what to write?")
            # end
          end
          empty.content do
            Components::NewPostDialog(world: @world) do |dialog|
              dialog.with_trigger_button do |button|
                button.inline_start_icon("huge/pencil-edit-01")
                span { "write your first post!" }
              end
            end
          end
        end
        div(class: "flex flex-col items-center") do
          Components::WorldNextPageControl(
            world: @world,
            post_type: @post_type,
            pagy: @pagy,
          )
        end
      end

      turbo_stream_from(@world, :posts, hidden: true)
    end
  end
end
