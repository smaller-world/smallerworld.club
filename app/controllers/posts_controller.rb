# typed: true
# frozen_string_literal: true

class PostsController < ApplicationController
  # == Actions ==

  # GET /world/:world_id/posts[?type_id=...][&favorited=1]
  def index
    current_user = Current.user!
    world = find_world
    authorize!(world, to: :show?)
    favorited = cast_boolean(params[:favorited])
    post_type = if (type_id = params[:type_id])
      world.post_types.find(type_id)
    end
    posts_scope = begin
      scope = world.posts
      if post_type
        scope = scope.where(type: post_type)
      end
      if favorited
        scope = scope.favorited
      end
      authorized_scope(scope)
        .reverse_chronological
        .with_rich_text_body_and_embeds
        .with_attached_images
        .includes(:type, :world_owner)
    end
    pagy, posts = pagy(:countless, posts_scope, limit: 5)
    post_ids = posts.map(&:id)
    if current_user == world.owner!
      reported_post_ids = Report
        .unresolved
        .where(reportable_type: "Post", reportable_id: post_ids)
        .pluck("DISTINCT reportable_id")
        .to_set
    else
      replied_post_ids = ReplyInitiation
        .where(post_id: post_ids, replier: current_user)
        .pluck("DISTINCT post_id")
        .to_set
    end
    respond_to do |format|
      if turbo_frame_request?
        format.html do
          render Views::Posts::Index.new(
            current_user:,
            world:,
            post_type:,
            posts:,
            pagy:,
            replied_post_ids:,
            reported_post_ids:,
          )
        end
      end
      format.turbo_stream do
        append_post_items = turbo_stream.append(
          "post_items",
          renderable: Components::WorldPostItems.new(
            current_user:,
            posts:,
            replied_post_ids:,
            reported_post_ids:,
          ),
        )
        replace_next_page_control = turbo_stream.replace(
          "next_page_control",
          renderable: Components::WorldNextPageControl.new(world:, post_type:, pagy:),
        )
        render turbo_stream: [ append_post_items, replace_next_page_control ]
      end
    end
  end

  # GET /world/:world_id/posts/new?type_id=...
  def new
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :post?)
        type_id = params.require(:type_id)
        post_type = world.post_types.find(type_id)
        post = post_type.posts.build
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
          post: [ :type_id, :emoji, :title, :body, :quiet, images: [], recipient_ids: [] ],
        )
        post_type_id = post_params.delete(:type_id)
        post_type = world.post_types.find(post_type_id)
        post = post_type.posts.build(**post_params)
        if post.save
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
          post: [
            :type_id,
            :emoji,
            :title,
            :body,
            :quiet,
            images: [],
            recipient_ids: [],
          ],
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

  # POST /posts/:id/favorite
  def favorite
    respond_to do |format|
      format.turbo_stream do
        current_user = Current.user!
        post = find_post
        authorize!(post)
        if post.favorite
          render turbo_stream: turbo_stream.replace(
            helpers.dom_id(post, :card),
            renderable: Components::PostCard.new(
              current_user:,
              post:,
              replied: false,
            ),
          )
        else
          message = "failed to favorite post"
          description = post.errors.full_messages.first
          render(
            turbo_stream: append_toast(message, description:),
            status: :internal_server_error,
          )
        end
      end
    end
  end

  # POST /posts/:id/unfavorite
  def unfavorite
    respond_to do |format|
      format.turbo_stream do
        current_user = Current.user!
        post = find_post
        authorize!(post)
        if post.unfavorite
          render turbo_stream: turbo_stream.replace(
            helpers.dom_id(post, :card),
            renderable: Components::PostCard.new(
              current_user:,
              post:,
              replied: false,
            ),
          )
        else
          message = "failed to unfavorite post"
          description = post.errors.full_messages.first
          render(
            turbo_stream: append_toast(message, description:),
            status: :internal_server_error,
          )
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
        world = post.world!
        post.destroy!
        refresh_or_redirect_to(world, status: :see_other)
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
