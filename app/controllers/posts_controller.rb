# typed: true
# frozen_string_literal: true

class PostsController < ApplicationController
  # == Actions ==

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
    raise NotImplementedError
  end

  # POST /world/:world_id/posts
  def create
    respond_to do |format|
      format.html do
        world = find_world
        post_params = params.expect(post: [ :title, :plain_body ])
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
    raise NotImplementedError
  end

  # DELETE /posts/:id
  def destroy
    raise NotImplementedError
  end

  private

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end

  sig { returns(Post) }
  def find_post
    Post.find(params.fetch(:post_id))
  end
end
