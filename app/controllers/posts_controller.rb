# typed: true
# frozen_string_literal: true

class PostsController < ApplicationController
  # == Actions ==

  # GET /world/:world_id/posts
  def index
    current_user = Current.user!
    world = find_world
    authorize!(world, to: :show?)
    posts_scope = authorized_scope(world.posts)
      .reverse_chronological
      .with_rich_text_body_and_embeds
      .with_attached_images
    pagy, posts = pagy(:countless, posts_scope, limit: 5)
    replied_post_ids = ReplyInitiation
      .where(post_id: posts.map(&:id), replier: current_user)
      .pluck(:post_id)
      .to_set
    respond_to do |format|
      if turbo_frame_request?
        format.html do
          render Views::Posts::Index.new(world:, posts:, pagy:, replied_post_ids:)
        end
      end
      format.turbo_stream do
        append_post_items = turbo_stream.append(
          :post_items,
          renderable: Components::WorldPostItems.new(posts:, replied_post_ids:),
        )
        update_next_page_control = if pagy.next
          turbo_stream.replace(
            :next_page_control,
            renderable: Components::WorldNextPageControl.new(world:, pagy:),
          )
        else
          turbo_stream.remove(:next_page_control)
        end
        render turbo_stream: [ append_post_items, update_next_page_control ]
      end
    end
  end

  # GET /world/:world_id/posts/new
  def new
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :post?)
        post = world.posts.build
        render Views::Posts::New.new(post:)
      end
    end
  end

  # GET /posts/:id/edit
  def edit
    respond_to do |format|
      format.html do
        post = find_post
        authorize!(post, to: :edit?)
        render Views::Posts::Edit.new(post:)
      end
    end
  end

  # POST /world/:world_id/posts
  def create
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :post?)
        post_params = params.expect(
          post: [ :emoji, :title, :body, images: [], world_key_colors: [] ],
        )
        post = world.posts.build(**post_params)
        if post.save
          refresh_or_redirect_to(world)
        else
          render Views::Posts::New.new(post:), status: :unprocessable_content
        end
      end
    end
  end

  # PUT/PATCH /posts/:id
  def update
    respond_to do |format|
      format.html do
        post = find_post
        authorize!(post)
        post_params = params.expect(
          post: [ :emoji, :title, :body, images: [], world_key_colors: [] ],
        )
        if post.update(post_params)
          refresh_or_redirect_to(post.world!)
        else
          render Views::Posts::Edit.new(post:), status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /posts/:id
  def destroy
    respond_to do |format|
      format.html do
        post = find_post
        authorize!(post)
        post.destroy!
        redirect_to(post.world!)
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Post) }
  def find_post
    Post.find(params.fetch(:id))
  end

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end
end
