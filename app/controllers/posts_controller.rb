# typed: true
# frozen_string_literal: true

class PostsController < ApplicationController
  # == Actions ==

  # GET /world/:world_id/posts?type_id=...&created_post_id=...
  def index
    current_user = Current.user!
    world = find_world
    authorize!(world, to: :show?)
    post_type = if (type_id = params[:type_id])
      world.post_types.find(type_id)
    end
    posts_scope = begin
      scope = world.posts
      scope = if post_type
        scope.where(type: post_type)
      elsif world.owner! == current_user
        scope
      else
        scope.loud
      end
      authorized_scope(scope)
        .reverse_chronological
        .with_rich_text_body_and_embeds
        .with_attached_images
        .includes(:type, :world_owner)
    end
    pagy, posts = pagy(:countless, posts_scope, limit: 5)
    post_ids = posts.map(&:id)
    replied_post_ids = if current_user != world.owner!
      ReplyInitiation
        .where(post_id: post_ids, replier: current_user)
        .pluck("DISTINCT post_id")
        .to_set
    end
    respond_to do |format|
      if turbo_frame_request?
        format.html do
          created_post_id = params[:created_post_id]
          render Views::Posts::Index.new(
            world:,
            post_type:,
            posts:,
            pagy:,
            replied_post_ids:,
            created_post_id:,
          )
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
            renderable: Components::WorldNextPageControl.new(world:, post_type:, pagy:),
          )
        else
          turbo_stream.remove(:next_page_control)
        end
        render turbo_stream: [ append_post_items, update_next_page_control ]
      end
    end
  end

  # GET /world/:world_id/posts/new[?type_id=...]
  def new
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :post?)
        post = if (type_id = params[:type_id])
          post_type = world.post_types.find(type_id)
          post_type.posts.build
        else
          Post.new
        end
        restore_draft = cast_boolean(params[:restore_draft])
        render Views::Posts::New.new(post:, restore_draft:)
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
          post: [ :type_id, :emoji, :title, :body, :quiet, images: [] ],
        )
        post_type_id = post_params.delete(:type_id)
        post_type = world.post_types.find(post_type_id)
        post = post_type.posts.build(**post_params)
        if post.save
          flash[:created_post_id] = post.id
          refresh_or_redirect_to([ world, anchor: helpers.dom_id(post, :card) ])
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
          post: [ :type_id, :emoji, :title, :body, :quiet, images: [] ],
        )
        if post.update(post_params)
          world = post.world!
          refresh_or_redirect_to([ world, anchor: helpers.dom_id(post, :card) ])
        else
          render Views::Posts::Edit.new(post:), status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /posts/:id
  def destroy
    respond_to do |format|
      format.turbo_stream do
        post = find_post
        authorize!(post)
        post.destroy!
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
