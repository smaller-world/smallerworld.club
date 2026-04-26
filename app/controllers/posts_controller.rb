# typed: true
# frozen_string_literal: true

class PostsController < ApplicationController
  # == Actions ==

  # GET /world/:world_id/posts
  def index
    respond_to do |format|
      format.turbo_stream do
        world = find_world
        pagy, posts = pagy(
          :countless,
          world.posts.reverse_chronological,
          limit: 5,
        )
        append_posts = turbo_stream.append(
          :posts,
          renderable: Components::WorldPostItems.new(posts:),
        )
        update_next_page_control = if pagy.next
          turbo_stream.replace(
            :next_page_control,
            renderable: Components::WorldNextPageControl.new(world:, pagy:),
          )
        else
          turbo_stream.remove(:next_page_control)
        end
        render turbo_stream: [ append_posts, update_next_page_control ]
      end
    end
  end

  # GET /world/:world_id/posts/new
  def new
    respond_to do |format|
      format.html do
        world = find_world
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
        render Views::Posts::Edit.new(post:)
      end
    end
  end

  # POST /world/:world_id/posts
  def create
    respond_to do |format|
      format.html do
        world = find_world
        post_params = params.expect(post: [ :title, :body ])
        post = world.posts.build(**post_params)
        if post.save
          redirect_to(world)
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
        post_params = params.expect(post: [ :title, :body ])
        if post.update(post_params)
          redirect_to(post.world!)
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
