# typed: true
# frozen_string_literal: true

class WorldsController < ApplicationController
  # GET /worlds
  def index
    # respond_to do |format|
    #   format.html do
    #     current_user = current_user!
    #     render Views::Worlds::Index.new(current_user:)
    #   end
    # end
  end

  # GET /worlds/:id
  # GET /@:id
  def show
    respond_to do |format|
      format.html do
        world = find_world
        if allowed_to?(:show?, world)
          # pagy, posts = pagy(
          #   :countless,
          #   world.posts
          #     .reverse_chronological
          #     .with_rich_text_body_and_embeds
          #     .with_attached_images,
          #   limit: 5,
          # )
          render Views::Worlds::Show.new(world:)
        else
          redirect_to(root_path, alert: "You don't have access to this world")
        end
      end
    end
  end

  # GET /worlds/new
  def new
    respond_to do |format|
      format.html do
        current_user = current_user!
        world = current_user.build_own_world
        render Views::Worlds::New.new(world:)
      end
    end
  end

  # GET /worlds/:id/edit
  def edit
    respond_to do |format|
      format.html do
        world = find_world
        render Views::Worlds::Edit.new(world:)
      end
    end
  end

  # POST /worlds
  def create
    respond_to do |format|
      format.html do
        current_user = current_user!
        world_params = params.expect(world: [ :name, :blurb, :icon ])
        world = current_user.build_own_world(**world_params)
        if world.save
          redirect_to(world)
        else
          render Views::Worlds::New.new(world:), status: :unprocessable_content
        end
      end
    end
  end

  # PUT /worlds/:id
  def update
    respond_to do |format|
      format.html do
        world = find_world
        world_params = params.expect(world: [ :name, :blurb, :icon ])
        if world.update(**world_params)
          redirect_to(world)
        else
          render Views::Worlds::Edit.new(world:), status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /worlds/:id
  def destroy
    raise NotImplementedError
  end

  private

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:id))
  end
end
